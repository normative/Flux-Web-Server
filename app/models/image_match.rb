class ImageMatch < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :image

  validates_presence_of :image_id, :match_image_id, :qw, :qx, :qy, :qz, :t1, :t2, :t3  

  def as_json(options = {})
    super(options.merge(
                          except: [ :created_at, :updated_at]
                        ))
  end

end
