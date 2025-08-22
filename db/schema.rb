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

ActiveRecord::Schema[8.0].define(version: 2025_08_15_011907) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "contractors", force: :cascade do |t|
    t.string "name"
    t.string "contact_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "jwt_denylists", force: :cascade do |t|
    t.string "jti"
    t.datetime "exp"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["jti"], name: "index_jwt_denylists_on_jti"
  end

  create_table "material_request_suppliers", force: :cascade do |t|
    t.bigint "material_request_id", null: false
    t.bigint "supplier_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["material_request_id", "supplier_id"], name: "index_material_req_suppliers_on_material_req_id_and_supplier_id", unique: true
    t.index ["material_request_id"], name: "index_material_request_suppliers_on_material_request_id"
    t.index ["supplier_id"], name: "index_material_request_suppliers_on_supplier_id"
  end

  # TODO: Add status, open, fulfilled, cancelled
  create_table "material_requests", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.text "description"
    t.decimal "quantity"
    t.string "unit"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_material_requests_on_project_id"
  end

  create_table "projects", force: :cascade do |t|
    t.bigint "contractor_id", null: false
    t.string "name"
    t.text "description"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["contractor_id"], name: "index_projects_on_contractor_id"
  end

  create_table "quotes", force: :cascade do |t|
    t.bigint "material_request_id", null: false
    t.bigint "supplier_id", null: false
    t.decimal "price"
    t.integer "lead_time_days"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["material_request_id"], name: "index_quotes_on_material_request_id"
    t.index ["supplier_id"], name: "index_quotes_on_supplier_id"
  end

  create_table "suppliers", force: :cascade do |t|
    t.string "name"
    t.string "contact_email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "contractor_id"
    t.bigint "supplier_id"
    t.index ["contractor_id"], name: "index_users_on_contractor_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["supplier_id"], name: "index_users_on_supplier_id"
  end

  add_foreign_key "material_request_suppliers", "material_requests"
  add_foreign_key "material_request_suppliers", "suppliers"
  add_foreign_key "material_requests", "projects"
  add_foreign_key "projects", "contractors"
  add_foreign_key "quotes", "material_requests"
  add_foreign_key "quotes", "suppliers"
  add_foreign_key "users", "contractors"
  add_foreign_key "users", "suppliers"
end
