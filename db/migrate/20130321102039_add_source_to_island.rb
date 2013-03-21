class AddSourceToIsland < ActiveRecord::Migration
  def change
    add_column :islands, :source, :string
  end
end
