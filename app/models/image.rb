class Image < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :user
  belongs_to :camera
  belongs_to :category
  has_and_belongs_to_many :tags
  has_attached_file :image, styles: { thumb: "200x200", oriented: '100%' }, dependent: :destroy, convert_options: {
    oriented: "-auto-orient"
  }
  validates_presence_of :raw_latitude, :raw_longitude, :raw_altitude, :raw_yaw, :raw_pitch, :raw_roll,
                        :raw_q1, :raw_q2, :raw_q3, :raw_q4,  
                        :user, :camera, :heading, :image, :time_stamp

  def as_json(options = {})
    super(options.merge(
                        except: [ :raw_latitude, :raw_longitude, :raw_altitude, :raw_yaw, :raw_pitch, :raw_roll,
                                  :raw_q1, :raw_q2, :raw_q3, :raw_q4,
                                  :best_latitude, :best_longitude, :best_altitude, :best_yaw, :best_pitch, :best_roll,
                                  :best_q1, :best_q2, :best_q3, :best_q4,
                                  :image_file_name, :image_content_type, :image_file_size, :image_updated_at ],
                        methods: [ :latitude, :longitude, :altitude, :yaw, :pitch, :roll, :friendly_date ]
                        ))
    
  end

  def latitude; raw_latitude; end
  def longitude; raw_longitude; end
  def altitude; raw_altitude; end
  def yaw; raw_yaw; end
  def pitch; raw_pitch; end
  def roll; raw_roll; end
  def q1; raw_q1; end
  def q2; raw_q2; end
  def q3; raw_q3; end
  def q4; raw_q4; end

  def latitude= latitude; self.raw_latitude = self.best_latitude = latitude; end
  def longitude= longitude; self.raw_longitude = self.best_longitude = longitude; end
  def altitude= altitude; self.raw_altitude = self.best_altitude = altitude; end
  def yaw= yaw; self.raw_yaw = self.best_yaw = yaw; end
  def pitch= pitch ; self.raw_pitch = self.best_pitch = pitch; end
  def roll= roll; self.raw_roll = self.best_roll = roll; end
  def q1= q1; self.raw_q1 = self.best_q1 = q1; end
  def q2= q2; self.raw_q2 = self.best_q2 = q2; end
  def q3= q3; self.raw_q3 = self.best_q3 = q3; end
  def q4= q4; self.raw_q4 = self.best_q4 = q4; end

  def self.within lat, lng, radius
    where("(6371 * acos(cos(radians(#{lat})) * cos(radians(raw_latitude)) * cos(radians(raw_longitude) - radians(#{lng})) + sin(radians(#{lat})) * sin(radians(raw_latitude)))) < #{radius}")
  end
  
  def self.filtered lat, lng, radius, minalt, maxalt, mintime, maxtime, taglist, userlist, catlist
    from("filteredquery(#{lat}, #{lon}, #{radius}, #{minalt}, #{maxalt}, #{mintime}, #{maxtime}, #{taglist}, #{userlist}, #{catlist})") 
  end

  def friendly_date
    time_stamp.strftime '%b %-d, %Y'
  end

  def to_s; image.original_filename; end
end
