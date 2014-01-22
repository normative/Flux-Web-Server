require 'facebook'
require 'twitter_client'

class User < ActiveRecord::Base
  devise :database_authenticatable, :registerable, :recoverable, :trackable, :validatable, :timeoutable

  include ActiveModel::ForbiddenAttributesProtection

  has_many :cameras, dependent: :destroy
  has_many :images, dependent: :destroy
  has_many :connections, class_name: 'Friend', dependent: :destroy
  has_many :friends, through: :connections, source: :user, class_name: 'User'
  has_attached_file :avatar, styles: { thumb: "140x140", smallthumb: "40x40", oriented: '100%' }, dependent: :destroy, convert_options: {
    oriented: "-auto-orient"
  }

  before_save :ensure_authentication_token
  before_validation :merge_facebook_data, :merge_twitter_data

  attr_accessor :facebook, :twitter
  
  validates(:username,
            presence: true,
            uniqueness: { message: 'is taken', case_sensitive: true },
            format: { with: /\A[a-zA-Z0-9_\-\.]*\Z/, message: 'must contain only letters, numbers, underscores, periods or dashes' },
            length: { in: 4..16 })

  def as_json(options = {})
    super(options.merge(
                        except: [ :encrypted_password, :reset_password_token, :reset_password_sent_at, 
                                  :authentication_token, :created_at, :updated_at, 
                                  :avatar_file_name, :avatar_content_type, :avatar_file_size, :avatar_updated_at
                                  ]
                         ))
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
  
  def self.usernameisunique uname
    select("*").from("usernameisunique('#{uname}')") 
  end

  def self.getprofile auth, userid
    select("*").from("getprofileforuser('#{auth}', #{userid})")     
  end

  def self.find_from_facebook me
    where(:provider => 'facebook', :uid => me['id'].to_s).first || raise(ActiveRecord::RecordNotFound)
  end

  def self.find_from_twitter me
    where(:provider => 'twitter', :uid => me.id.to_s).first || raise(ActiveRecord::RecordNotFound)
  end

  def merge_facebook_data
    if new_record? && facebook.present?
      fbuser = OAuth2::Facebook.lookup_by_token facebook
      if fbuser.present?
        self.provider = 'facebook'
        self.uid = fbuser['id']
        self.password = self.password_confirmation = Devise.friendly_token[0,20]
      end
    end
    true
  end

  def merge_twitter_data
    if new_record? && twitter.present?
      twuser = TwitterClient.lookup_by_token twitter
      if twuser.present?
        self.provider = 'twitter'
        self.uid = twuser.id
        self.password = self.password_confirmation = Devise.friendly_token[0,20]
      end
    end
    true
  end

  def to_s; username; end
end
