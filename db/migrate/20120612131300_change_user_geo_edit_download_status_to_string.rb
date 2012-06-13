class ChangeUserGeoEditDownloadStatusToString < ActiveRecord::Migration
  def up
    change_column :user_geo_edit_downloads, :status, :string
  end

  def down
    change_column :user_geo_edit_downloads, :status, :integer
  end
end
