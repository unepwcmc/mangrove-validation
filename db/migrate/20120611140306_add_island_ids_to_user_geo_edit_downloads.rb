class AddIslandIdsToUserGeoEditDownloads < ActiveRecord::Migration
  def change
    add_column :user_geo_edit_downloads, :island_ids, :text
    remove_column :user_geo_edit_downloads, :layer
    remove_column :user_geo_edit_downloads, :generated_at
  end
end
