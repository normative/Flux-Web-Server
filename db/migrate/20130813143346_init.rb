class Init < ActiveRecord::Migration
  def up
    create_table "cameras" do |t|
      t.references "user",   :null => false
      t.string  "model",       :limit => 32
      t.string  "deviceid",    :limit => 32,  :null => false
      t.string  "description", :limit => 256
      t.string  "nickname",    :limit => 64
      t.timestamps
    end

    create_table "categories" do |t|
      t.string "cat_description", :limit => 128, :null => false
      t.string "cat_text",        :limit => 32,  :null => false
      t.timestamps
    end

    create_table "friends" do |t|
      t.integer "user_id", :null => false
      t.integer "friend_id", :null => false
      t.timestamps
    end

    add_index "friends", ["friend_id"]
    add_index "friends", ["user_id"]

    create_table "images_tags" do |t|
      t.references 'image', :null => false
      t.references 'tag', :null => false
      t.timestamps
    end

    create_table "images" do |t|
      t.float    "raw_latitude",                                   :null => false
      t.float    "raw_longitude",                                  :null => false
      t.float    "raw_altitude",                                   :null => false
      t.float    "best_latitude"
      t.float    "best_longitude"
      t.float    "best_altitude"
      t.float    "raw_yaw",                                        :null => false
      t.float    "raw_pitch",                                      :null => false
      t.float    "raw_roll",                                       :null => false
      t.float    "best_yaw"
      t.float    "best_pitch"
      t.float    "best_roll"
      t.string   "description",    :limit => 256
      t.references  "category",   :null => false
      t.references  "user",   :null => false
      t.references  "camera",   :null => false
      t.float    "heading",                       :default => 0.0, :null => false
      t.timestamps
    end

    add_index "images", ["best_latitude"], :name => "image_latitude_idx"
    add_index "images", ["best_longitude"], :name => "image_longitude_idx"
    add_index "images", ["created_at"], :name => "image_created_at_cluster_idx"

    create_table "tags" do |t|
      t.string "tagtext", :limit => 32, :null => false
      t.timestamps
    end

    add_index "tags", ["tagtext"], :name => "tags_tagtext_cluster_idx", :unique => true

    create_table "users" do |t|
      t.string  "firstname", :limit => 32
      t.string  "lastname",  :limit => 64
      t.boolean "privacy", :null => false
      t.string  "nickname",  :limit => 64
      t.timestamps
    end
  end
end
