class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :recoverable, :trackable, :validatable, :timeoutable #, :omniauthable, :omniauth_providers => [:facebook]

  include ActiveModel::ForbiddenAttributesProtection

  has_many :cameras, dependent: :destroy
  has_many :images, dependent: :destroy
  has_many :connections, class_name: 'Friend', dependent: :destroy
  has_many :friends, through: :connections, source: :user, class_name: 'User'
  has_attached_file :avatar, styles: { thumb: "140x140", smallthumb: "40x40", oriented: '100%' }, dependent: :destroy, convert_options: {
    oriented: "-auto-orient"
  }

  before_save :ensure_authentication_token
  before_create do
#    self.privacy = false
    true
  end

  validates(:username,
            presence: true,
            uniqueness: { message: 'is taken', case_sensitive: true },
            format: { with: /\A[a-zA-Z0-9_\-\.]*\Z/, message: 'must contain only letters, numbers, underscores, periods or dashes' },
            length: { in: 4..16 })

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
  
  def self.usernameisunique uname
    select("*").from("usernameisunique('#{uname}')") 
  end

  def self.getprofile auth, userid
    select("*").from("getprofileforuser('#{auth}', #{userid})")     
  end

  def to_s; username; end
end
