class AddNameAndInstitutionToUsers < ActiveRecord::Migration
  def change
    add_column :users, :name, :string

    add_column :users, :institution, :string

  end
end
