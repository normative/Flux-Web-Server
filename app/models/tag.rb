class Tag < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  has_and_belongs_to_many :images

  validates_presence_of :tag_text

  def to_s; tag_text; end

  def self.getlocalbycount lat, lng, radius, maxrows
    select("*").from("tagsbylocalcount(#{lat}, #{lng}, #{radius}, #{maxrows})") 
  end

  def self.getlocalbycountfiltered lat, lng, radius, minalt, maxalt, mintime, maxtime, taglist, userlist, catlist
    select("*").from("tagsbylocalcountfiltered(#{lat}, #{lng}, #{radius}, #{minalt}, #{maxalt}, #{mintime}, #{maxtime}, #{taglist}, #{userlist}, #{catlist})") 
  end
  
end
