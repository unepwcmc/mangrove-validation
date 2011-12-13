class AddIndexToClassifications < ActiveRecord::Migration
  def self.up
    add_index :classifications, [:parent_x, :parent_y, :parent_z, :user_id], :name => 'parents_and_user_id'
  end

  def self.down
    remove_index :classifications, [:parent_x, :parent_y, :parent_z, :user_id], :name => 'parents_and_user_id'
  end
end
