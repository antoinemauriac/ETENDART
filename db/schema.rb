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

ActiveRecord::Schema[7.0].define(version: 2023_03_31_095856) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "unaccent"

  create_table "academies", force: :cascade do |t|
    t.string "name"
    t.bigint "manager_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["manager_id"], name: "index_academies_on_manager_id"
  end

  create_table "academy_enrollments", force: :cascade do |t|
    t.bigint "student_id", null: false
    t.bigint "academy_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["academy_id"], name: "index_academy_enrollments_on_academy_id"
    t.index ["student_id"], name: "index_academy_enrollments_on_student_id"
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "activities", force: :cascade do |t|
    t.string "name"
    t.bigint "camp_id", null: false
    t.bigint "category_id", null: false
    t.bigint "coach_id", null: false
    t.integer "min_capacity"
    t.integer "max_capacity"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "days"
    t.bigint "location_id"
    t.index ["camp_id"], name: "index_activities_on_camp_id"
    t.index ["category_id"], name: "index_activities_on_category_id"
    t.index ["coach_id"], name: "index_activities_on_coach_id"
    t.index ["location_id"], name: "index_activities_on_location_id"
  end

  create_table "activity_enrollments", force: :cascade do |t|
    t.bigint "student_id", null: false
    t.bigint "activity_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activity_id"], name: "index_activity_enrollments_on_activity_id"
    t.index ["student_id"], name: "index_activity_enrollments_on_student_id"
  end

  create_table "camp_enrollments", force: :cascade do |t|
    t.bigint "student_id", null: false
    t.bigint "camp_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["camp_id"], name: "index_camp_enrollments_on_camp_id"
    t.index ["student_id"], name: "index_camp_enrollments_on_student_id"
  end

  create_table "camps", force: :cascade do |t|
    t.string "name"
    t.date "starts_at"
    t.date "ends_at"
    t.bigint "school_period_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_period_id"], name: "index_camps_on_school_period_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "coach_academies", force: :cascade do |t|
    t.bigint "academy_id", null: false
    t.bigint "coach_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["academy_id"], name: "index_coach_academies_on_academy_id"
    t.index ["coach_id"], name: "index_coach_academies_on_coach_id"
  end

  create_table "coach_camps", force: :cascade do |t|
    t.bigint "camp_id", null: false
    t.bigint "coach_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["camp_id"], name: "index_coach_camps_on_camp_id"
    t.index ["coach_id"], name: "index_coach_camps_on_coach_id"
  end

  create_table "coach_categories", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.bigint "coach_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_coach_categories_on_category_id"
    t.index ["coach_id"], name: "index_coach_categories_on_coach_id"
  end

  create_table "course_enrollments", force: :cascade do |t|
    t.bigint "student_id", null: false
    t.bigint "course_id", null: false
    t.boolean "present", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_course_enrollments_on_course_id"
    t.index ["student_id"], name: "index_course_enrollments_on_student_id"
  end

  create_table "courses", force: :cascade do |t|
    t.datetime "starts_at"
    t.datetime "ends_at"
    t.bigint "activity_id", null: false
    t.bigint "manager_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "coach_id"
    t.boolean "status", default: false
    t.index ["activity_id"], name: "index_courses_on_activity_id"
    t.index ["coach_id"], name: "index_courses_on_coach_id"
    t.index ["manager_id"], name: "index_courses_on_manager_id"
  end

  create_table "days", force: :cascade do |t|
    t.string "day_of_week"
    t.datetime "start_time"
    t.datetime "end_time"
    t.bigint "activity_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activity_id"], name: "index_days_on_activity_id"
  end

  create_table "enrollments", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "feedbacks", force: :cascade do |t|
    t.string "content"
    t.bigint "student_id", null: false
    t.bigint "coach_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["coach_id"], name: "index_feedbacks_on_coach_id"
    t.index ["student_id"], name: "index_feedbacks_on_student_id"
  end

  create_table "locations", force: :cascade do |t|
    t.string "address"
    t.bigint "academy_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "city"
    t.string "zipcode"
    t.string "country"
    t.decimal "lat", precision: 9, scale: 6
    t.decimal "lng", precision: 9, scale: 6
    t.string "street_address"
    t.index ["academy_id"], name: "index_locations_on_academy_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "school_period_enrollments", force: :cascade do |t|
    t.bigint "student_id", null: false
    t.bigint "school_period_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_period_id"], name: "index_school_period_enrollments_on_school_period_id"
    t.index ["student_id"], name: "index_school_period_enrollments_on_student_id"
  end

  create_table "school_periods", force: :cascade do |t|
    t.string "name"
    t.bigint "academy_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "year"
    t.index ["academy_id"], name: "index_school_periods_on_academy_id"
  end

  create_table "students", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email"
    t.date "date_of_birth"
    t.string "address"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.string "gender"
    t.string "phone_number"
    t.string "city"
    t.integer "zipcode"
  end

  create_table "user_roles", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "role_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role_id"], name: "index_user_roles_on_role_id"
    t.index ["user_id"], name: "index_user_roles_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "first_name"
    t.string "last_name"
    t.string "phone_number"
    t.string "status"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "academies", "users", column: "manager_id"
  add_foreign_key "academy_enrollments", "academies"
  add_foreign_key "academy_enrollments", "students"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "activities", "camps"
  add_foreign_key "activities", "categories"
  add_foreign_key "activities", "locations"
  add_foreign_key "activities", "users", column: "coach_id"
  add_foreign_key "activity_enrollments", "activities"
  add_foreign_key "activity_enrollments", "students"
  add_foreign_key "camp_enrollments", "camps"
  add_foreign_key "camp_enrollments", "students"
  add_foreign_key "camps", "school_periods"
  add_foreign_key "coach_academies", "academies"
  add_foreign_key "coach_academies", "users", column: "coach_id"
  add_foreign_key "coach_camps", "camps"
  add_foreign_key "coach_camps", "users", column: "coach_id"
  add_foreign_key "coach_categories", "categories"
  add_foreign_key "coach_categories", "users", column: "coach_id"
  add_foreign_key "course_enrollments", "courses"
  add_foreign_key "course_enrollments", "students"
  add_foreign_key "courses", "activities"
  add_foreign_key "courses", "users", column: "coach_id"
  add_foreign_key "courses", "users", column: "manager_id"
  add_foreign_key "days", "activities"
  add_foreign_key "feedbacks", "students"
  add_foreign_key "feedbacks", "users", column: "coach_id"
  add_foreign_key "locations", "academies"
  add_foreign_key "school_period_enrollments", "school_periods"
  add_foreign_key "school_period_enrollments", "students"
  add_foreign_key "school_periods", "academies"
  add_foreign_key "user_roles", "roles"
  add_foreign_key "user_roles", "users"
end
