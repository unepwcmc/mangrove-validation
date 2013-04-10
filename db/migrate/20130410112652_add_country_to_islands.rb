class AddCountryToIslands < ActiveRecord::Migration
  def change
    add_column :islands, :country, :string
  end
end
