class Image < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  belongs_to :user
  belongs_to :camera
  belongs_to :category
  has_and_belongs_to_many :tags
  has_attached_file :image, styles: { thumb: "200x200", oriented: '100%' }, dependent: :destroy, convert_options: {
    oriented: "-auto-orient"
  }
  validates_presence_of :raw_latitude, :raw_longitude, :raw_altitude, :raw_yaw, :raw_pitch, :raw_roll, :user, :camera, :heading, :image

  def as_json(options = {})
    super(options.merge(
                        except: [ :raw_latitude, :raw_longitude, :raw_altitude, :raw_yaw, :raw_pitch, :raw_roll,
                                  :best_latitude, :best_longitude, :best_altitude, :best_yaw, :best_pitch, :best_roll,
                                  :image_file_name, :image_content_type, :image_file_size, :image_updated_at ],
                        methods: [ :latitude, :longitude, :altitude, :yaw, :pitch, :roll ]
                        ))
    
  end

  def latitude; raw_latitude; end
  def longitude; raw_longitude; end
  def altitude; raw_altitude; end
  def yaw; raw_yaw; end
  def pitch; raw_pitch; end
  def roll; raw_roll; end

  def latitude= latitude; self.raw_latitude = self.best_latitude = latitude; end
  def longitude= longitude; self.raw_longitude = self.best_longitude = longitude; end
  def altitude= altitude; self.raw_altitude = self.best_altitude = altitude; end
  def yaw= yaw; self.raw_yaw = self.best_yaw = yaw; end
  def pitch= pitch ; self.raw_pitch = self.best_pitch = pitch; end
  def roll= roll; self.raw_roll = self.best_roll = roll; end

  def self.within lat, lng, radius
    where("(6371 * acos(cos(radians(#{lat})) * cos(radians(raw_latitude)) * cos(radians(raw_longitude) - radians(#{lng})) + sin(radians(#{lat})) * sin(radians(raw_latitude)))) < #{radius}")
  end

  def to_s; image.original_filename; end
end
