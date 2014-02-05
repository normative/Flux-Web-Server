class Connection < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :user

  validates_presence_of :user_id, :connections_id

  # connection type: 1 = follower, 2 = friend, 0 = no connection (record can be deleted)
  # connection status: 1 = request pending, 2 = request accepted, 4 = request rejected
  
  def self.getfriends myid
    select("*").from("getfriends('#{myid}')") 
  end

  def self.getfollowing myid, dir
    # dir = 0 => i am following...
    # dir = 1 => ... are following me
    select("*").from("getfollowers('#{myid}', #{dir})") 
  end
  
  def self.getfriendinvites myid
    select("*").from("getfriendinvites('#{myid}')") 
  end

end
