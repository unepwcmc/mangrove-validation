class CreateLayers < ActiveRecord::Migration
  def change
    create_table :layers do |t|
      t.text :polygon

      t.timestamps
    end
  end
end
