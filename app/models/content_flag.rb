class ContentFlag < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :user
  belongs_to :image
  
  validates_presence_of :image_id, :user_id  

  def as_json(options = {})
    super(options.merge(
                          except: [ :created_at, :updated_at]
                        ))
  end
end
