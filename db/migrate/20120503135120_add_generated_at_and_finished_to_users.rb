class AddGeneratedAtAndFinishedToUsers < ActiveRecord::Migration
  def change
    add_column :users, :generated_at, :datetime
    add_column :users, :finished, :boolean
  end
end
