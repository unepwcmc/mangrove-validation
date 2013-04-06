class AddLocationToDownload < ActiveRecord::Migration
  def change
    add_column :user_geo_edit_downloads, :file_id, :string
  end
end
