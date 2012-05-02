class AddKnowledgeToLayers < ActiveRecord::Migration
  def change
    add_column :layers, :knowledge, :string

  end
end
