class RemoveFinishedFromUserGeoEditDownload < ActiveRecord::Migration
  def up
    remove_column :user_geo_edit_downloads, :finished
  end

  def down
    change_table :user_geo_edit_downloads do |t|
      t.boolean :finished, :default => false
    end
  end
end
