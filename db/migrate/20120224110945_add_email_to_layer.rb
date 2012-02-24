class AddEmailToLayer < ActiveRecord::Migration
  def change
    add_column :layers, :email, :string
  end
end
