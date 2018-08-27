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

ActiveRecord::Schema.define(version: 20180826142517) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "pages", force: :cascade do |t|
    t.text     "content"
    t.string   "digest"
    t.string   "url"
    t.integer  "sec"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "push_channel"
    t.boolean  "stop_fetch",   default: false
    t.text     "content_diff"
    t.string   "title"
    t.boolean  "enable_js",    default: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "channel"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
    t.string   "device_token"
    t.string   "device_type"
    t.string   "locale_identifier"
    t.string   "time_zone"
    t.string   "endpoint_arn"
    t.boolean  "enabled",           default: true
  end

  add_index "users", ["channel"], name: "index_users_on_channel", unique: true, using: :btree

end
