class Map < ActiveRecord::Base
  before_create :populate_parent

  def populate_parent
    self.parent_x = zoom_out(x)
    self.parent_y = zoom_out(y)
    self.parent_z = 15
  end

  def zoom_out coord
    ((coord/2).floor/2)
  end
  
  def self.random_map_cell
    find(:first, :order => "random()")
  end
  
  def game_json
    {
      :id => id,
      :x => x,
      :y => y,
      :z => z
    }
  end
end