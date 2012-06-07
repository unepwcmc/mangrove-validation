class AddReallocatedFromIslandIdToUserGeoEdit < ActiveRecord::Migration
  def change
    add_column :user_geo_edits, :reallocated_from_island_id, :integer
  end
end
