# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_09_04_053421) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "chat_sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "title"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "updated_at"], name: "index_chat_sessions_on_user_id_and_updated_at"
    t.index ["user_id"], name: "index_chat_sessions_on_user_id"
  end

  create_table "conversation_summaries", force: :cascade do |t|
    t.bigint "chat_session_id", null: false
    t.text "content", null: false
    t.integer "turn_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_session_id", "created_at"], name: "index_conversation_summaries_on_chat_session_id_and_created_at"
    t.index ["chat_session_id"], name: "index_conversation_summaries_on_chat_session_id"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "chat_session_id", null: false
    t.integer "role", default: 0, null: false
    t.text "content", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["chat_session_id", "created_at"], name: "index_messages_on_chat_session_id_and_created_at"
    t.index ["chat_session_id"], name: "index_messages_on_chat_session_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "chat_sessions", "users"
  add_foreign_key "conversation_summaries", "chat_sessions"
  add_foreign_key "messages", "chat_sessions"
end
