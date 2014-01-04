class Image < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :user
  belongs_to :camera
  belongs_to :category
  has_and_belongs_to_many :tags
  has_attached_file :image, styles: { thumb: "200x200", 
                                  quarterhd: "960x960", 
                                   oriented: '100%', 
                                   features: {:processors => [:feature_extractor], :format => :xml}
                                    }, 
                         dependent: :destroy, 
                   convert_options: { oriented: "-auto-orient" }
                              
  validates_presence_of :raw_latitude, :raw_longitude, :raw_altitude, :raw_yaw, :raw_pitch, :raw_roll,
                        :raw_qw, :raw_qx, :raw_qy, :raw_qz,  
                        :user, :camera, :heading, :image, :time_stamp

  def as_json(options = {})
    super(options.merge(
                        except: [ :raw_latitude, :raw_longitude, :raw_altitude, :raw_yaw, :raw_pitch, :raw_roll,
                                  :raw_qw, :raw_qx, :raw_qy, :raw_qz,
                                  :best_latitude, :best_longitude, :best_altitude, :best_yaw, :best_pitch, :best_roll,
                                  :best_qw, :best_qx, :best_qy, :best_qz,
                                  :image_file_name, :image_content_type, :image_file_size, :image_updated_at, :image_created_at ]
#                        methods: [ :latitude, :longitude, :altitude, :yaw, :pitch, :roll,
#                                    :qw, :qx, :qy, :qz ]
                        ))
    
  end

 # def latitude; best_latitude; end
 # def longitude; best_longitude; end
 # def altitude; best_altitude; end
 # def yaw; best_yaw; end
 # def pitch; best_pitch; end
 # def roll; best_roll; end
 # def qw; best_qw; end
 # def qx; best_qx; end
 # def qy; best_qy; end
 # def qz; best_qz; end

  def latitude= latitude; self.raw_latitude = self.best_latitude = latitude; end
  def longitude= longitude; self.raw_longitude = self.best_longitude = longitude; end
  def altitude= altitude; self.raw_altitude = self.best_altitude = altitude; end
  def yaw= yaw; self.raw_yaw = self.best_yaw = yaw; end
  def pitch= pitch ; self.raw_pitch = self.best_pitch = pitch; end
  def roll= roll; self.raw_roll = self.best_roll = roll; end
  def qw= qw; self.raw_qw = self.best_qw = qw; end
  def qx= qx; self.raw_qx = self.best_qx = qx; end
  def qy= qy; self.raw_qy = self.best_qy = qy; end
  def qz= qz; self.raw_qz = self.best_qz = qz; end

  def self.filtered myid, lat, lng, radius, minalt, maxalt, mintime, maxtime, taglist, userlist, catlist
    select("*").from("filteredmeta('#{myid}', #{lat}, #{lng}, #{radius}, #{minalt}, #{maxalt}, #{mintime}, #{maxtime}, #{taglist}, #{userlist}, #{catlist}, 100)") 
  end

  def self.filteredcontent myid, lat, lng, radius, minalt, maxalt, mintime, maxtime, taglist, userlist, catlist, maxcount
 #   select("*").from(      "filteredquery(#{lat}, #{lng}, #{radius}, #{minalt}, #{maxalt}, #{mintime}, #{maxtime}, #{taglist}, #{userlist}, #{catlist})")
    select("*").from("filteredcontentquery('#{myid}', #{lat}, #{lng}, #{radius}, #{minalt}, #{maxalt}, #{mintime}, #{maxtime}, #{taglist}, #{userlist}, #{catlist}, #{maxcount})") 
  end

  def self.filteredmeta myid, lat, lng, radius, minalt, maxalt, mintime, maxtime, taglist, userlist, catlist, maxcount
    select("*").from("filteredmeta('#{myid}', #{lat}, #{lng}, #{radius}, #{minalt}, #{maxalt}, #{mintime}, #{maxtime}, #{taglist}, #{userlist}, #{catlist}, #{maxcount})") 
  end

  def to_s; image.original_filename; end

  # still used for nuke
  def self.within lat, lng, radius
#    where("(6371000 * acos(cos(radians(#{lat})) * cos(radians(best_latitude)) * cos(radians(best_longitude) - radians(#{lng})) + sin(radians(#{lat})) * sin(radians(best_latitude)))) < #{radius}")
    select("*").from("filteredmeta(#{myid}, #{lat}, #{lng}, #{radius}, -100000, 100000, NULL, NULL, NULL, NULL, NULL, 1000)") 
  end

#  def self.oldwithin lat, lng, radius
#    where("(6371000 * acos(cos(radians(#{lat})) * cos(radians(best_latitude)) * cos(radians(best_longitude) - radians(#{lng})) + sin(radians(#{lat})) * sin(radians(best_latitude)))) < #{radius}")
#  end

#  def self.filteredtimebucket myid, lat, lng, radius, minalt, maxalt, mintime, maxtime, taglist, userlist, catlist, maxcount
#    select("*").from("filteredquery(#{lat}, #{lng}, #{radius}, #{minalt}, #{maxalt}, #{mintime}, #{maxtime}, #{taglist}, #{userlist}, #{catlist}, #{maxcount})") 
#  end

#  def self.extendedmeta idlist
#    select("*").from("getextendedmeta(#{idlist})") 
#  end

end
