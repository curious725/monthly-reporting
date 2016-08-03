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

ActiveRecord::Schema.define(version: 20160725091159) do

  create_table "approval_requests", force: :cascade do |t|
    t.integer  "manager_id",          limit: 4
    t.integer  "vacation_request_id", limit: 4
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "approval_requests", ["vacation_request_id"], name: "index_approval_requests_on_vacation_request_id", using: :btree

  create_table "available_vacations", force: :cascade do |t|
    t.integer  "kind",           limit: 4,  default: 0
    t.float    "available_days", limit: 24
    t.integer  "user_id",        limit: 4
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "available_vacations", ["user_id"], name: "index_available_vacations_on_user_id", using: :btree

  create_table "holidays", force: :cascade do |t|
    t.string   "description", limit: 255
    t.date     "start"
    t.integer  "duration",    limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "reports", force: :cascade do |t|
    t.string   "body",       limit: 255
    t.integer  "user_id",    limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  add_index "reports", ["user_id"], name: "index_reports_on_user_id", using: :btree

  create_table "team_roles", force: :cascade do |t|
    t.integer  "role",       limit: 4, default: 0
    t.integer  "user_id",    limit: 4
    t.integer  "team_id",    limit: 4
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "team_roles", ["team_id"], name: "index_team_roles_on_team_id", using: :btree
  add_index "team_roles", ["user_id"], name: "index_team_roles_on_user_id", using: :btree

  create_table "teams", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "first_name",             limit: 255
    t.string   "last_name",              limit: 255
    t.string   "position",               limit: 255
    t.date     "birth_date"
    t.string   "username",               limit: 255
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: ""
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "invitation_token",       limit: 255
    t.datetime "invitation_created_at"
    t.datetime "invitation_sent_at"
    t.datetime "invitation_accepted_at"
    t.integer  "invitation_limit",       limit: 4
    t.integer  "invited_by_id",          limit: 4
    t.string   "invited_by_type",        limit: 255
    t.integer  "invitations_count",      limit: 4,   default: 0
    t.date     "employment_date"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["invitation_token"], name: "index_users_on_invitation_token", unique: true, using: :btree
  add_index "users", ["invitations_count"], name: "index_users_on_invitations_count", using: :btree
  add_index "users", ["invited_by_id"], name: "index_users_on_invited_by_id", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

  create_table "vacation_requests", force: :cascade do |t|
    t.integer  "kind",       limit: 4, default: 0
    t.date     "start_date"
    t.date     "end_date"
    t.integer  "status",     limit: 4, default: 0
    t.integer  "user_id",    limit: 4
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  add_index "vacation_requests", ["user_id"], name: "index_vacation_requests_on_user_id", using: :btree

  add_foreign_key "approval_requests", "vacation_requests"
  add_foreign_key "available_vacations", "users"
  add_foreign_key "reports", "users"
  add_foreign_key "team_roles", "teams"
  add_foreign_key "team_roles", "users"
  add_foreign_key "vacation_requests", "users"
end
