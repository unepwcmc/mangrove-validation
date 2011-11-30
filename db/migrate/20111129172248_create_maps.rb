class CreateMaps < ActiveRecord::Migration
  def self.up
    create_table :maps do |t|
      t.integer :x
      t.integer :y
      t.integer :z
      t.integer :parent_x
      t.integer :parent_y
      t.integer :parent_z

      t.timestamps
    end
  end

  def self.down
    drop_table :maps
  end
end
