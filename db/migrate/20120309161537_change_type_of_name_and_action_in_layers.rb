class ChangeTypeOfNameAndActionInLayers < ActiveRecord::Migration
  def up
    add_column :layers, :new_name, :integer
    add_column :layers, :new_action, :integer
    Layer.all.each do |l|
      l.new_name = Names.value_for(l.name.upcase)
      l.new_action = Actions.value_for(l.action.upcase)
      l.save(:validate => false)
    end
    remove_column :layers, :name
    remove_column :layers, :action
    rename_column :layers, :new_name, :name
    rename_column :layers, :new_action, :action
  end

  def down
    add_column :layers, :new_name, :string
    add_column :layers, :new_action, :string
    Layer.all.each do |l|
      l.new_name = Names.key_for(l.name).to_s
      l.new_action = Actions.key_for(l.action).to_s
      l.save(:validate => false)
    end
    remove_column :layers, :name
    remove_column :layers, :action
    rename_column :layers, :new_name, :name
    rename_column :layers, :new_action, :action
  end
end
