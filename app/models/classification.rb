class Classification < ActiveRecord::Base
  belongs_to :track
  belongs_to :cell
  belongs_to :user
  attr_accessible :x, :y, :z, :parent_x, :parent_y, :parent_z, :value, :track, :cell, :position
  after_save :update_stats

  
  before_create :populate_parent
  
  def populate_parent
    self.parent_x = zoom_out(x)
    self.parent_y = zoom_out(y)
    self.parent_z = 15
  end
  
  def zoom_out coord
    ((coord/2).floor/2)
  end

#  def validate_on_update
#    if changes["value"].first != nil
#      errors.add(:value, "can't reclassify an existing classification")
#    end  
#  end
    
  def update_stats
#    if self.position == APP_CONFIG[:cells_per_track] -1
    self.track.user.refresh_stats
#      self.track.update_attribute :finished_at, Time.now
#    end
    self.cell.update_totals self.value
  end
  
  
  def game_json    
    {
      :id => id,
      :x  => x,
      :y  => y,
      :z  => z,
      :value  => value
    }
  end
end