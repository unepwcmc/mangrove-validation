class Country < ActiveRecord::Base
  has_many :islands, :foreign_key => :iso_3, :primary_key => :iso_3

end
