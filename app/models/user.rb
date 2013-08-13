class User < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  has_many :cameras, dependent: :destroy
  has_many :images, dependent: :destroy
  has_many :connections, class_name: 'Friend', dependent: :destroy
  has_many :friends, through: :connections, source: :user, class_name: 'User'

  before_create do
    self.privacy = false
    true
  end

  def to_s; nickname; end
end
