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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20131106145137) do

  create_table "cameras", force: true do |t|
    t.integer  "user_id",                 null: false
    t.string   "model",       limit: 32
    t.string   "deviceid",    limit: 32,  null: false
    t.string   "description", limit: 256
    t.string   "nickname",    limit: 64
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "categories", force: true do |t|
    t.string   "cat_description", limit: 128, null: false
    t.string   "cat_text",        limit: 32,  null: false
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
  end

  create_table "friends", force: true do |t|
    t.integer  "user_id",    null: false
    t.integer  "friend_id",  null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "friends", ["friend_id"], name: "index_friends_on_friend_id", using: :btree
  add_index "friends", ["user_id"], name: "index_friends_on_user_id", using: :btree

  create_table "images", force: true do |t|
    t.float    "raw_latitude",                                  null: false
    t.float    "raw_longitude",                                 null: false
    t.float    "raw_altitude",                                  null: false
    t.float    "best_latitude"
    t.float    "best_longitude"
    t.float    "best_altitude"
    t.float    "raw_yaw",                                       null: false
    t.float    "raw_pitch",                                     null: false
    t.float    "raw_roll",                                      null: false
    t.float    "best_yaw"
    t.float    "best_pitch"
    t.float    "best_roll"
    t.string   "description",         limit: 256
    t.integer  "category_id",                                   null: false
    t.integer  "user_id",                                       null: false
    t.integer  "camera_id",                                     null: false
    t.float    "heading",                         default: 0.0, null: false
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
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
    t.float    "horiz_accuracy",                  default: 0.0
    t.float    "vert_accuracy",                   default: 0.0
    t.float    "location_confidence",             default: 0.0
  end

  add_index "images", ["best_latitude"], name: "image_latitude_idx", using: :btree
  add_index "images", ["best_longitude"], name: "image_longitude_idx", using: :btree
  add_index "images", ["time_stamp"], name: "image_timestamp_cluster_idx", using: :btree

  create_table "images_tags", force: true do |t|
    t.integer  "image_id",   limit: 8, null: false
    t.integer  "tag_id",               null: false
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "images_tags", ["image_id"], name: "images_tags_image_id_idx", using: :btree
  add_index "images_tags", ["tag_id"], name: "images_tags_tag_id_idx", using: :btree

  create_table "tags", force: true do |t|
    t.string   "tagtext",    limit: 32, null: false
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "tags", ["tagtext"], name: "tags_tagtext_cluster_idx", unique: true, using: :btree

  create_table "users", force: true do |t|
    t.string   "name",                   limit: 64
    t.string   "username",               limit: 64,              null: false
    t.string   "email",                             default: "", null: false
    t.string   "encrypted_password",                default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.integer  "sign_in_count",                     default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "authentication_token"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", unique: true, using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

end
