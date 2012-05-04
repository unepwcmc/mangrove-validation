class CreateLayerDownloads < ActiveRecord::Migration
  def change
    create_table :layer_downloads do |t|
      t.string :name
      t.integer :layer
      t.integer :status
      t.datetime :generated_at
      t.boolean :finished

      t.timestamps
    end
  end
end
