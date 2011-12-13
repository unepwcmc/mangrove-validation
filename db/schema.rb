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

ActiveRecord::Schema.define(:version => 20111213120131) do

  create_table "cells", :force => true do |t|
    t.integer  "positive_count", :default => 0
    t.integer  "negative_count", :default => 0
    t.integer  "x"
    t.integer  "y"
    t.integer  "z"
    t.integer  "parent_x"
    t.integer  "parent_y"
    t.integer  "parent_z"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "mangroves"
  end

  add_index "cells", ["parent_x", "parent_y", "parent_z"], :name => "index_cells_on_parent_x_and_parent_y_and_parent_z"
  add_index "cells", ["x", "y", "z"], :name => "index_cells_on_x_and_y_and_z"

  create_table "classifications", :force => true do |t|
    t.integer  "x"
    t.integer  "y"
    t.integer  "z"
    t.boolean  "value"
    t.integer  "position"
    t.integer  "track_id"
    t.integer  "cell_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_x"
    t.integer  "parent_y"
    t.integer  "parent_z"
    t.integer  "user_id"
  end

  add_index "classifications", ["parent_x", "parent_y", "parent_z", "user_id"], :name => "parents_and_user_id"
  add_index "classifications", ["x", "y", "z"], :name => "index_classifications_on_x_and_y_and_z"

  create_table "tracks", :force => true do |t|
    t.datetime "finished_at"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "username"
    t.string   "crypted_password",                   :null => false
    t.string   "password_salt",                      :null => false
    t.string   "persistence_token",                  :null => false
    t.string   "single_access_token",                :null => false
    t.string   "perishable_token",                   :null => false
    t.integer  "login_count",         :default => 0, :null => false
    t.integer  "failed_login_count",  :default => 0, :null => false
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
    t.string   "email"
    t.integer  "meters_explored",     :default => 0
    t.integer  "rank"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["rank"], :name => "index_users_on_rank"

end
