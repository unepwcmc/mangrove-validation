class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation, :remember_me

  attr_accessible :name, :institution, :generated_at, :finished, :usage_agreement

  validates :name, presence: true
  validates :usage_agreement, presence: true

  has_many :user_geo_edits
  has_many :user_geo_edits_downloads
end
