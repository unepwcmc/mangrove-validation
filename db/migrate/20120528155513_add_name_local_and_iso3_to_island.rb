class AddNameLocalAndIso3ToIsland < ActiveRecord::Migration
  def change
    add_column :islands, :name_local, :string
    add_column :islands, :iso_3, :string
  end
end
