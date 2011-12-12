class RemoveMapsTable < ActiveRecord::Migration
  def up
    drop_table :maps
    add_column :cells, :mangroves, :boolean
  end

  def down
    create_table :maps do |t|
      t.integer :x
      t.integer :y
      t.integer :z
      t.integer :parent_x
      t.integer :parent_y
      t.integer :parent_z

      t.timestamps
    end
    remove_column :cells, :mangroves
  end
end
