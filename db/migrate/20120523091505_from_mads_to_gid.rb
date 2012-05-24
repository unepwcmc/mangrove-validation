class FromMadsToGid < ActiveRecord::Migration
  def up
    rename_table :layers, :user_geo_edits
  
    remove_column :user_geo_edits, :name
    change_column :user_geo_edits, :action, :string
    add_column :user_geo_edits, :island_id, :integer
  end

  def down
    add_column :user_geo_edits, :name, :integer
    change_column :user_geo_edits, :action, :integer
    remove_column :user_geo_edits, :island_id

    rename_table :user_geo_edits, :layers
  end
end
