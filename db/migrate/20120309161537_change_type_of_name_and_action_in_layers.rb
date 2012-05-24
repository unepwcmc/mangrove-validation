class ChangeTypeOfNameAndActionInLayers < ActiveRecord::Migration
  def up
    add_column :layers, :new_name, :integer
    add_column :layers, :new_action, :integer
    remove_column :layers, :name
    remove_column :layers, :action
    rename_column :layers, :new_name, :name
    rename_column :layers, :new_action, :action
  end

  def down
    add_column :layers, :new_name, :string
    add_column :layers, :new_action, :string
    remove_column :layers, :name
    remove_column :layers, :action
    rename_column :layers, :new_name, :name
    rename_column :layers, :new_action, :action
  end
end
