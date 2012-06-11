class AddUserToUserGeoEditDownloads < ActiveRecord::Migration
  def change
    add_column :user_geo_edit_downloads, :user_id, :integer
  end
end
