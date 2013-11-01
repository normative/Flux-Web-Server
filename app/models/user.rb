class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :recoverable, :trackable, :validatable, :timeoutable, :omniauthable, :omniauth_providers => [:facebook]

  include ActiveModel::ForbiddenAttributesProtection

  has_many :cameras, dependent: :destroy
  has_many :images, dependent: :destroy
  has_many :connections, class_name: 'Friend', dependent: :destroy
  has_many :friends, through: :connections, source: :user, class_name: 'User'

  before_save :ensure_authentication_token
  before_create do
    self.privacy = false
    true
  end

  def ensure_authentication_token
    if authentication_token.blank?
      self.authentication_token = generate_authentication_token
    end
  end
  
  private

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    end
  end
  
  def to_s; nickname; end
end
