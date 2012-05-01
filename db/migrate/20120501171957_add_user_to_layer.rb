class AddUserToLayer < ActiveRecord::Migration
  def up
    add_column :layers, :user_id, :integer
    remove_column :layers, :email
  end

  def down
    remove_column :layers, :user_id
    add_column :layers, :email, :string
  end
end
