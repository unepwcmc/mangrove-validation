class FromMadsToGid < ActiveRecord::Migration
  def up
    remove_column :layers, :name
    change_column :layers, :action, :string
  end

  def down
    add_column :layers, :name, :integer
    change_column :layers, :action, :integer
  end
end
