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

ActiveRecord::Schema[7.1].define(version: 2026_04_25_090425) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "operation_logs", force: :cascade do |t|
    t.bigint "payment_id", null: false
    t.string "action"
    t.string "result"
    t.string "worker_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["payment_id"], name: "index_operation_logs_on_payment_id"
  end

  create_table "payments", force: :cascade do |t|
    t.string "merchant_id"
    t.decimal "amount"
    t.string "currency"
    t.string "status"
    t.string "failure_reason"
    t.integer "retry_count"
    t.integer "risk_score"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "operation_logs", "payments"
end
