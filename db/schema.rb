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

ActiveRecord::Schema.define(version: 2020_07_21_082958) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "budget_categories", force: :cascade do |t|
    t.string "name"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "special", default: false
    t.index ["deleted_at"], name: "index_budget_categories_on_deleted_at"
  end

  create_table "cards", force: :cascade do |t|
    t.string "number"
    t.bigint "team_id"
    t.bigint "user_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["deleted_at"], name: "index_cards_on_deleted_at"
    t.index ["team_id"], name: "index_cards_on_team_id"
    t.index ["user_id"], name: "index_cards_on_user_id"
  end

  create_table "merchants", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "budget_category_id"
    t.index ["budget_category_id"], name: "index_merchants_on_budget_category_id"
    t.index ["code"], name: "index_merchants_on_code"
    t.index ["deleted_at"], name: "index_merchants_on_deleted_at"
    t.index ["name"], name: "index_merchants_on_name"
  end

  create_table "teams", force: :cascade do |t|
    t.string "name"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slack_id"
    t.boolean "default", default: false
    t.string "group"
    t.index ["deleted_at"], name: "index_teams_on_deleted_at"
  end

  create_table "transactions", force: :cascade do |t|
    t.integer "amount_cents", default: 0, null: false
    t.string "amount_currency", default: "USD", null: false
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.string "investec_id"
    t.bigint "team_id"
    t.bigint "budget_category_id"
    t.string "confirmation_state", default: "unconfirmed"
    t.bigint "confirmed_by_id"
    t.string "description"
    t.string "token"
    t.bigint "card_id"
    t.datetime "date"
    t.index ["budget_category_id"], name: "index_transactions_on_budget_category_id"
    t.index ["card_id"], name: "index_transactions_on_card_id"
    t.index ["confirmed_by_id"], name: "index_transactions_on_confirmed_by_id"
    t.index ["deleted_at"], name: "index_transactions_on_deleted_at"
    t.index ["team_id"], name: "index_transactions_on_team_id"
    t.index ["user_id"], name: "index_transactions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "role"
    t.string "name"
    t.string "email", default: "", null: false
    t.string "slack_id"
    t.bigint "team_id"
    t.datetime "deleted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "admin", default: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.index ["deleted_at"], name: "index_users_on_deleted_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
    t.index ["team_id"], name: "index_users_on_team_id"
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "cards", "teams"
  add_foreign_key "cards", "users"
  add_foreign_key "merchants", "budget_categories"
  add_foreign_key "transactions", "budget_categories"
  add_foreign_key "transactions", "cards"
  add_foreign_key "transactions", "teams"
  add_foreign_key "transactions", "users"
  add_foreign_key "transactions", "users", column: "confirmed_by_id"
  add_foreign_key "users", "teams"
end
