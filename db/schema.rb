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

ActiveRecord::Schema.define(version: 20200424204618) do

  create_table "articles", force: :cascade do |t|
    t.integer "fiverr_order_id"
    t.datetime "due_date"
    t.integer "order_type_id"
    t.integer "writers_id"
    t.decimal "price"
    t.integer "writingstatus_id"
    t.text "comments"
    t.string "url"
    t.string "key_word"
    t.string "writing_code"
    t.integer "article_amount"
    t.integer "word_count"
    t.integer "payment_status_id"
    t.datetime "payment_date"
    t.string "payment_details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["fiverr_order_id"], name: "index_articles_on_fiverr_order_id"
    t.index ["order_type_id"], name: "index_articles_on_order_type_id"
    t.index ["payment_status_id"], name: "index_articles_on_payment_status_id"
    t.index ["writers_id"], name: "index_articles_on_writers_id"
    t.index ["writingstatus_id"], name: "index_articles_on_writingstatus_id"
  end

  create_table "extras_statuses", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "fiverr_orders", force: :cascade do |t|
    t.string "order_no"
    t.string "username"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "order_type_id"
    t.integer "order_status_id"
    t.integer "server_id"
    t.boolean "custom_offer"
    t.boolean "site_audit"
    t.integer "site_audit_status"
    t.boolean "articles"
    t.boolean "traffic"
    t.integer "site_traffic_status"
    t.boolean "login_data"
    t.integer "login_data_status"
    t.datetime "start_date"
    t.boolean "rank_tracker"
    t.text "comments"
    t.datetime "due_date"
    t.integer "extras_status_id"
    t.index ["extras_status_id"], name: "index_fiverr_orders_on_extras_status_id"
    t.index ["order_status_id"], name: "index_fiverr_orders_on_order_status_id"
    t.index ["order_type_id"], name: "index_fiverr_orders_on_order_type_id"
    t.index ["server_id"], name: "index_fiverr_orders_on_server_id"
  end

  create_table "order_statuses", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "order_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "payment_statuses", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "servers", force: :cascade do |t|
    t.string "name"
    t.string "status"
    t.string "comments"
    t.string "last_reset"
    t.string "problems"
    t.string "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "writers", force: :cascade do |t|
    t.string "name"
    t.string "comments"
    t.string "work_details"
    t.integer "priority"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "writingstatuses", force: :cascade do |t|
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
