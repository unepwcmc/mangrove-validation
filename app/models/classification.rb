class Classification < ActiveRecord::Base
  belongs_to :track
  belongs_to :cell
  attr_accessible :x, :y, :z, :value, :track, :cell, :position
  after_update :update_stats
    
#  def validate_on_update
#    if changes["value"].first != nil
#      errors.add(:value, "can't reclassify an existing classification")
#    end  
#  end
    
  def update_stats
    if self.position == APP_CONFIG[:cells_per_track] -1      
      self.track.user.refresh_stats      
      self.track.update_attribute :finished_at, Time.now
    end  
    self.cell.update_totals self.value
  end  
end
