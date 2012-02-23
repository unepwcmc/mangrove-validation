class Layer < ActiveRecord::Base
  validates :name, presence: true, inclusion: { in: %w(mangrove coral), message: "%{value} is not a valid name" }
  validates :action, presence: true, inclusion: { in: %w(validate add delete), message: "%{value} is not a valid action" }
  validates :polygon, presence: true

  before_create do
    # SQL CartoDB
  end
end
