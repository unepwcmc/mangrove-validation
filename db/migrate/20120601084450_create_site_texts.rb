class CreateSiteTexts < ActiveRecord::Migration
  def change
    create_table :site_texts do |t|
      t.string :name
      t.string :string
      t.string :text
      t.string :text

      t.timestamps
    end
  end
end
