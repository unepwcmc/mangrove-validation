class Cell < ActiveRecord::Base
  has_many :classifications
  has_many :tracks, :through => :classifications
  attr_accessible :positive_count, :negative_count, :x, :y, :z, :parent_x, :parent_y, :parent_z
  #validates_presence_of 
  #index [:x,:y,:z]
  #index [:parent_x,:parent_y,:parent_z]
  
  before_create :populate_parent
  
  def populate_parent
    self.parent_x = zoom_out(x)
    self.parent_y = zoom_out(y)
    self.parent_z = 15
  end
  
  def zoom_out coord
    ((coord/2).floor/2)
  end
  
  def game_json
    {:id => id,
     :x => x,
     :y => y,
     :z => z,
     :positive_count => positive_count,
     :negative_count => negative_count,
     :total_count => positive_count + negative_count}
  end
  
  def update_totals value
    value == true ? self.increment!(:positive_count) : self.increment!(:negative_count)
  end
end
