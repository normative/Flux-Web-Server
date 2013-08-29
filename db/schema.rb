# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130828212257) do

  create_table "cameras", :force => true do |t|
    t.integer  "user_id",                    :null => false
    t.string   "model",       :limit => 32
    t.string   "deviceid",    :limit => 32,  :null => false
    t.string   "description", :limit => 256
    t.string   "nickname",    :limit => 64
    t.datetime "created_at",                 :null => false
    t.datetime "updated_at",                 :null => false
  end

  create_table "categories", :force => true do |t|
    t.string   "cat_description", :limit => 128, :null => false
    t.string   "cat_text",        :limit => 32,  :null => false
    t.datetime "created_at",                     :null => false
    t.datetime "updated_at",                     :null => false
  end

  create_table "friends", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.integer  "friend_id",  :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "friends", ["friend_id"], :name => "index_friends_on_friend_id"
  add_index "friends", ["user_id"], :name => "index_friends_on_user_id"

  create_table "images", :force => true do |t|
    t.float    "raw_latitude",                                       :null => false
    t.float    "raw_longitude",                                      :null => false
    t.float    "raw_altitude",                                       :null => false
    t.float    "best_latitude"
    t.float    "best_longitude"
    t.float    "best_altitude"
    t.float    "raw_yaw",                                            :null => false
    t.float    "raw_pitch",                                          :null => false
    t.float    "raw_roll",                                           :null => false
    t.float    "best_yaw"
    t.float    "best_pitch"
    t.float    "best_roll"
    t.string   "description",        :limit => 256
    t.integer  "category_id",                                        :null => false
    t.integer  "user_id",                                            :null => false
    t.integer  "camera_id",                                          :null => false
    t.float    "heading",                           :default => 0.0, :null => false
    t.datetime "created_at",                                         :null => false
    t.datetime "updated_at",                                         :null => false
    t.string   "image_file_name"
    t.string   "image_content_type"
    t.integer  "image_file_size"
    t.datetime "image_updated_at"
    t.datetime "time_stamp"
    t.float    "raw_qw"
    t.float    "raw_qx"
    t.float    "raw_qy"
    t.float    "raw_qz"
    t.float    "best_qw"
    t.float    "best_qx"
    t.float    "best_qy"
    t.float    "best_qz"
  end

  add_index "images", ["best_latitude"], :name => "image_latitude_idx"
  add_index "images", ["best_longitude"], :name => "image_longitude_idx"
  add_index "images", ["created_at"], :name => "image_created_at_cluster_idx"

  create_table "images_tags", :force => true do |t|
    t.integer  "image_id",   :null => false
    t.integer  "tag_id",     :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "tags", :force => true do |t|
    t.string   "tagtext",    :limit => 32, :null => false
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

  add_index "tags", ["tagtext"], :name => "tags_tagtext_cluster_idx", :unique => true

  create_table "users", :force => true do |t|
    t.string   "firstname",  :limit => 32
    t.string   "lastname",   :limit => 64
    t.boolean  "privacy",                  :null => false
    t.string   "nickname",   :limit => 64
    t.datetime "created_at",               :null => false
    t.datetime "updated_at",               :null => false
  end

end
