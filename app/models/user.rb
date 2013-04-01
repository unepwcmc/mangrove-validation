class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  attr_accessible :email, :password, :password_confirmation, :remember_me,
    :name, :institution, :generated_at, :finished, :usage_agreement, :downloads_agreement

  validates :institution, presence: true
  validates :name, presence: true
  validates :usage_agreement, presence: true

  has_many :user_geo_edits
  has_many :user_geo_edits_downloads
end
