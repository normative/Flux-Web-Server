class Camera < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :user
  has_many :images, dependent: :destroy

  validates_presence_of :user, :deviceid

  def to_s; nickname; end
end
