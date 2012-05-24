class CreateIslands < ActiveRecord::Migration
  def change
    create_table :islands do |t|
      t.string :name

      t.timestamps
    end
  end
end
