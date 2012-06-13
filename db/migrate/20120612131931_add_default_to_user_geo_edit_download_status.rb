class AddDefaultToUserGeoEditDownloadStatus < ActiveRecord::Migration
  def change
    change_table :user_geo_edit_downloads do |t|
      t.change :status, :string, :default => :active
    end
  end
end
