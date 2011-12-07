#Core movement class

class Explorer
  attr_accessor :x, :y, :z, :total_cells, :max_axis, :distance

  class Loc < Hashie::Dash
    property :x
    property :y
    property :z, :default => 17
    
    def to_s
      "[#{x},#{y}]"
    end
  end
    
  def initialize track, opts = {}
    opts.reverse_merge! :z => 17
    opts.reverse_merge! :x => rand(2**opts[:z]), 
                        :y => rand(2**opts[:z]), 
                        :distance => APP_CONFIG['cells_per_track']
    @loc          = Loc.new :x => opts[:x], :y => opts[:y], :z => opts[:z]
    @distance     = opts[:distance]
    @total_distance = opts[:distance]
    @total_cells  = (2**@loc.z)**2
    @max_axis     = 2**@loc.z
    @path         = []    
    @track        = track
    survey
    @path << @loc
  end
  

  def explore!
    return if @distance <= 1    
    survey if move
    explore!
  end
  
  # GAME SPACE
  # . ^ .
  # < y >
  # . v .
  # 
  # move to the cell with lowest number of surveys (on average)
  # avoid getting into loops (don't go to a cell where you touch own path)
  #
  # . v . . . .   
  # . v . . . .
  # . v < < . .
  # . v . ^ . .
  # . > > ^ . .
  #
  # if cell with nothing, go there first.
  #
  def move
    # Choose a random cell
    # JAVI: Extend this part of the method to choose cell with lower number of surveys (on average)
    cell = cells_around(@loc).rand
      
    # possibly a good location
    # first look ahead      
    if !touches_path? cell, @path, @loc      
      
      # do 1 more look ahead for each further possible step to avoid this:
      #
      # . . . . .
      # v < < . .
      # v . ^ . .
      # v . ^ < .
      # v . x o .
      # v x ? x .
      # > > ^ . .
      # . . . . . 
      #
      # ^v<>  = path
      # o     = start
      # ?     = possible good looking next move
      # x     = shows that this is a dead end. All further steps are not allowed.
      #
      # Therefore, if any further step from cell is possible, then we're good to go
      
      # Configure future
      future_path = @path.dup
      future_path << cell
      second_steps = cells_around(cell)
      
      # If at least one of the future steps is valid, go for it
      second_steps.each do |ss|
        if !touches_path? ss, future_path, cell
          @path << cell
          @loc = cell
          @distance -= 1      
          return true
        end
      end          
    end  
    
    Rails.logger.debug "*****************"
     Rails.logger.debug "Location: #{@loc.to_s}, New move: #{cell.to_s}."
     Rails.logger.debug "Path: #{@path.to_s}"  
      
    false      
    #cells = Cell.all :conditions => "(x = #{@x-1} AND y = #{@y}) OR (x = #{@x+1} AND y = #{@y}) OR (x = #{@x} AND y = #{@y-1}) OR (x = #{@x} AND y = #{@y+1})",
    #                 :order => "positive_count + negative_count ASC"
    
    # if all the cells have already been surveyed, weight index to those with few surveys                 
    #if cells.size == 4
    #  i = rand(3)
    #  i = (i - (i * 0.1)).floor      
    #  @x = cells[i].x
    #  @y = cells[i].y
    #  return
    #end
    
    # if there are empty cells, make a new cell where there's a gap and use that 
 #[@x, @y-1] *<-- ALWAYS GOING DOWN
    #existing_cells = cells.map {|c| [c.x, c.y]}
    #survey_cell = (possible_cells - existing_cells).rand
  end
  
  
  #survey a cell
  def survey
    cell = Cell.find_or_create_by_x_and_y_and_z(@loc.x, @loc.y, @loc.z)
    @track.classifications.create(:position => @total_distance - @distance, :cell => cell, :x => cell.x, :y => cell.y, :z => cell.z)
  end    
 
  
  # HELPER generate array of surrounding cells
  def cells_around cell, opts = {}
    opts.reverse_merge! :include_self => false
    
    ca = [Loc.new(:x => cell.x+1, :y => cell.y),
          Loc.new(:x => cell.x-1, :y => cell.y),
          Loc.new(:x => cell.x, :y => cell.y+1),
          Loc.new(:x => cell.x, :y => cell.y-1)]
    
    # add self if requested
    ca << cell if opts[:include_self]        
    
    # TODO: Check if the cells exist on the map!
    valid_ca = []
    ca.each do |cell_a|
      valid_ca << cell_a if Map.find_by_x_and_y_and_z(cell_a.x, cell_a.y, 17)
    end

    valid_ca
  end  
  
  # Tests if any possible cells around a cell touch or are in the current path
  # the parent is where the cell came from, it's ok to touch that
  #
  # If new cell is in path, or if touches path aside from current cell, no move.
  # This prevents the explorer from getting in to a dead end
  # And also helps to generates straighish tracks  
  def touches_path? cell, path, parent
    cell_touch = cells_around(cell, :include_self => true) - [parent]
    (cell_touch - path) == cell_touch ? false : true
  end  
end