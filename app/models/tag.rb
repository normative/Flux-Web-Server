class Tag < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  has_and_belongs_to_many :images

  validates_presence_of :tagtext

  def to_s; tagtext; end

  def self.getlocalbycount lat, lng, radius, maxcount
    select("*").from("tagsbylocalcount(#{lat}, #{lng}, #{radius}, #{maxcount})")
  end

  def self.getlocalbycountfiltered myid, lat, lng, radius, minalt, maxalt, mintime, maxtime, taglist, userlist, mypics, followingpics, maxcount
    select("*").from("tagsbylocalcountfiltered('#{myid}', #{lat}, #{lng}, #{radius}, #{minalt}, #{maxalt}, #{mintime}, #{maxtime}, #{taglist}, #{userlist}, #{mypics}, #{followingpics}, #{maxcount})")
  end

end
