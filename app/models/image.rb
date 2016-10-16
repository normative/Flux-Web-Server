require 'net/http'
require 'uri'

class Image < ActiveRecord::Base
  include ActiveModel::ForbiddenAttributesProtection

  after_create :generate_tags

  belongs_to :user
  belongs_to :camera
  belongs_to :category
  has_and_belongs_to_many :tags
#  has_attached_file :image, styles: { thumb: "200x200",
#                                  quarterhd: "960x960",
#                                   oriented: '100%',
#                                   features: {:processors => [:feature_extractor], :format => :xml}
#                                    },
#  has_attached_file :image, styles: { thumb: "200x200",
#                                  quarterhd: "960x960",
#                                   oriented: '100%',
#                                   features: { :format => :xml,
#                                               :chain_to => :oriented,
#                                               :processors => [:chainable, :feature_extractor]
#                                             }
#                                    },
  has_attached_file :image, styles: { thumbcrop: "184x184#",
                                  quarterhdcrop: "540x540#",
 #                                         thumb: "200x200",
 #                                     quarterhd: "960x960",
                                       oriented: '100%',
                                    binfeatures: { :format => :bin,
                                                   :chain_to => :oriented,
                                                   :processors => [:chainable, :feature_extractor]
                                                }#,
#                                      features: { :format => :xml,
#                                                  :cvt_to_xml => true,
#                                                  :chain_to => :binfeatures,
#                                                  :processors => [:chainable, :feature_extractor]
#                                                }
                                    },
                         dependent: :destroy,
                   convert_options: { oriented: "-auto-orient" }

  has_attached_file :historical, styles: { thumbcrop: "184x184#",
                                  quarterhdcrop: "540x540#",
#                                          thumb: "200x200",
#                                      quarterhd: "960x960",
                                       oriented: '100%'
                                    },
                         dependent: :destroy,
                   convert_options: { oriented: "-auto-orient" }

  # this attachment is actually created/setup by the feature compute node.
  # paperclip is attachment is defined to allow download through standard API
  has_attached_file :features, styles: { bin: { :format => :bin,
                                                   :processors => :feature_extractor
                                                 } },
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

  def self.filtered myid, lat, lng, radius, minalt, maxalt, mintime, maxtime, taglist, userlist
    select("*").from("filteredmeta('#{myid}', #{lat}, #{lng}, #{radius}, #{minalt}, #{maxalt}, #{mintime}, #{maxtime}, #{taglist}, #{userlist}, 0, 0, 0, 100)")
  end

  def self.filteredcontent myid, lat, lng, radius, minalt, maxalt, mintime, maxtime, taglist, userlist, mypics, followingpics, maxcount
 #   select("*").from(      "filteredquery(#{lat}, #{lng}, #{radius}, #{minalt}, #{maxalt}, #{mintime}, #{maxtime}, #{taglist}, #{userlist}, #{catlist})")
    select("*").from(" ('#{myid}', #{lat}, #{lng}, #{radius}, #{minalt}, #{maxalt}, #{mintime}, #{maxtime}, #{taglist}, #{userlist}, #{mypics}, #{followingpics}, #{maxcount})")
  end

  def self.filteredmeta myid, lat, lng, radius, minalt, maxalt, mintime, maxtime, taglist, userlist, mypics, followingpics, maxcount
    select("*").from("filteredmeta('#{myid}', #{lat}, #{lng}, #{radius}, #{minalt}, #{maxalt}, #{mintime}, #{maxtime}, #{taglist}, #{userlist}, #{mypics}, #{followingpics}, #{maxcount})")
  end

  def self.filteredimgcounts myid, lat, lng, radius, minalt, maxalt, mintime, maxtime, taglist, userlist, mypics, followingpics
    select("*").from("filteredimgcounts('#{myid}', #{lat}, #{lng}, #{radius}, #{minalt}, #{maxalt}, #{mintime}, #{maxtime}, #{taglist}, #{userlist}, #{mypics}, #{followingpics})")
  end

  def to_s; image.original_filename; end

  # still used for nuke
  def self.within lat, lng, radius
#    where("(6371000 * acos(cos(radians(#{lat})) * cos(radians(best_latitude)) * cos(radians(best_longitude) - radians(#{lng})) + sin(radians(#{lat})) * sin(radians(best_latitude)))) < #{radius}")
    select("*").from("filteredmeta(#{myid}, #{lat}, #{lng}, #{radius}, -100000, 100000, NULL, NULL, NULL, NULL, 1000)")
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
  def generate_tags
    #   curl -X POST \
    # -H 'Authorization: Bearer ICgn5t1EZkhRuPbH4mO2on0D7h7dZO' \
    # -H "Content-Type: application/json" \
    # -d '
    # {
    #   "inputs": [
    #     {
    #       "data": {
    #         "image": {
    #           "url": "https://samples.clarifai.com/metro-north.jpg"
    #         }
    #       }
    #     }
    #   ]
    # }'\
    # https://api.clarifai.com/v2/models/d3e9606952c34878b143f3b2f625ca68/outputs
    uri = URI.parse("https://api.clarifai.com/v2/models/d3e9606952c34878b143f3b2f625ca68/outputs")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.request_uri)

    request.add_field("Authorization", "Bearer ICgn5t1EZkhRuPbH4mO2on0D7h7dZO")
    request.add_field("Content-Type","application/json")
    data = Hash.new
    data["inputs"] = Array.new
    data["inputs"][0] = Hash.new
    data["inputs"][0]["data"] = Hash.new
    data["inputs"][0]["data"]["image"] = Hash.new
    data["inputs"][0]["data"]["image"]["url"] = self.image.url
    request.body = data.to_json
    response = http.request(request)
    predictions = JSON.parse(response.body)
    Rails.logger.info(predictions)
    predictions.data.concepts.each do |concept|
      if concept.value > 0.6
        tag = Tag.create!(:tagtext => concept.name)
        self.tags << tag
      end
    end
  end
end
