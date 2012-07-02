class AddDownloadsAgreementToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :downloads_agreement, :boolean
  end

  def self.down
    remove_column :users, :downloads_agreement
  end
end
