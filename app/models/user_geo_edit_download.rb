class UserGeoEditDownload < ActiveRecord::Base
  validates_inclusion_of :status, :in => [:active, :failed, :finished]

  belongs_to :user
end
