class Category < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  has_many :images

  validates_presence_of :cat_text, :cat_description

  def to_s; cat_text; end
end
