class Alias < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :user
#? belongs_to_many :relations

  validates_presence_of :alias_name, :user_id, :service_id
  

  def self.checkcontacts myid, contactlist, serviceid, maxcount
    select("*").from("checkcontacts('#{myid}', '#{contactlist}', #{serviceid}, #{maxcount})") 
  end

end
