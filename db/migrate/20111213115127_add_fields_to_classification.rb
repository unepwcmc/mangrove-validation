class AddFieldsToClassification < ActiveRecord::Migration
  def change
    add_column :classifications, :parent_x, :integer
    add_column :classifications, :parent_y, :integer
    add_column :classifications, :parent_z, :integer
    add_column :classifications, :user_id, :integer
  end
end
