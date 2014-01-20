class Connection < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :user

  validates_presence_of :user_id, :connections_id, :connection_type

end
