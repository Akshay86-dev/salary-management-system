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

ActiveRecord::Schema[8.1].define(version: 2026_10_15_140000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "departments", force: :cascade do |t|
    t.string "name", null: false
    t.decimal "budget", precision: 12, scale: 2
    t.bigint "manager_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_departments_on_name", unique: true
  end

  create_table "jwt_blacklists", force: :cascade do |t|
    t.string "jti", null: false
    t.datetime "exp", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_jwt_blacklists_on_jti", unique: true
  end

  create_table "locations", force: :cascade do |t|
    t.string "name", null: false
    t.string "address"
    t.string "city"
    t.string "state"
    t.string "zip_code"
    t.string "country", default: "USA"
    t.float "latitude"
    t.float "longitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["city", "state"], name: "index_locations_on_city_and_state"
    t.index ["name"], name: "index_locations_on_name"
  end

  create_table "salaries", force: :cascade do |t|
    t.bigint "employee_id", null: false
    t.decimal "amount", precision: 12, scale: 2, null: false
    t.string "currency", default: "USD", null: false
    t.integer "salary_type", default: 0, null: false
    t.date "effective_date", null: false
    t.boolean "is_current", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["employee_id", "is_current"], name: "index_salaries_on_employee_id_and_is_current"
    t.index ["employee_id", "salary_type"], name: "index_salaries_on_current_by_type", unique: true, where: "(is_current = true)"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "first_name"
    t.string "last_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "role", default: "EMPLOYEE", null: false
    t.string "employee_id"
    t.string "job_title"
    t.date "hire_date"
    t.bigint "department_id"
    t.bigint "location_id"
    t.boolean "is_active", default: true, null: false
    t.index "lower((email)::text)", name: "index_users_on_lower_email", unique: true
    t.index ["department_id"], name: "index_users_on_department_id"
    t.index ["employee_id"], name: "index_users_on_employee_id", unique: true, where: "(employee_id IS NOT NULL)"
    t.index ["location_id"], name: "index_users_on_location_id"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.check_constraint "role::text <> 'EMPLOYEE'::text OR employee_id IS NOT NULL AND job_title IS NOT NULL AND hire_date IS NOT NULL AND department_id IS NOT NULL AND location_id IS NOT NULL", name: "users_employee_details_required"
    t.check_constraint "role::text = ANY (ARRAY['EMPLOYEE'::character varying::text, 'HUMAN_RESOURCE'::character varying::text])", name: "users_role_allowed_values"
  end

  create_table "versions", force: :cascade do |t|
    t.string "whodunnit"
    t.datetime "created_at"
    t.bigint "item_id", null: false
    t.string "item_type", null: false
    t.string "event", null: false
    t.text "object"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "departments", "users", column: "manager_id"
  add_foreign_key "salaries", "users", column: "employee_id"
  add_foreign_key "users", "departments"
  add_foreign_key "users", "locations"
end
