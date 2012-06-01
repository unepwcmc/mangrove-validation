class RenameLayerDownloadToUserGeoEdit < ActiveRecord::Migration
  def up
    rename_table :layer_downloads, :user_geo_edit_downloads
  end

  def down
    rename_table :user_geo_edit_downloads, :layer_downloads
  end
end
