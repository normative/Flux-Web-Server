class Tag < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  has_and_belongs_to_many :images

  validates_presence_of :tag_text

  def to_s; tag_text; end
end
