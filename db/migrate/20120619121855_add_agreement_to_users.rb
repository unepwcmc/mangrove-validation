class AddAgreementToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :usage_agreement, :boolean
  end

  def self.down
    remove_column :users, :usage_agreement
  end
end
