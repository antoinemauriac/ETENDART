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

ActiveRecord::Schema[7.0].define(version: 2025_07_04_083700) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "unaccent"

  create_table "academies", force: :cascade do |t|
    t.string "name"
    t.bigint "manager_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "annual", default: false
    t.boolean "banished", default: false
    t.bigint "coordinator_id"
    t.string "city"
    t.boolean "new_format", default: false, null: false
    t.index ["coordinator_id"], name: "index_academies_on_coordinator_id"
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
    t.bigint "camp_id"
    t.bigint "category_id", null: false
    t.bigint "coach_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "location_id", null: false
    t.bigint "annual_program_id"
    t.boolean "annual", default: false
    t.boolean "age_restricted", null: false
    t.integer "min_age"
    t.integer "max_age"
    t.index ["annual_program_id"], name: "index_activities_on_annual_program_id"
    t.index ["camp_id"], name: "index_activities_on_camp_id"
    t.index ["category_id"], name: "index_activities_on_category_id"
    t.index ["coach_id"], name: "index_activities_on_coach_id"
    t.index ["location_id"], name: "index_activities_on_location_id"
  end

  create_table "activity_coaches", force: :cascade do |t|
    t.bigint "coach_id", null: false
    t.bigint "activity_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["activity_id"], name: "index_activity_coaches_on_activity_id"
    t.index ["coach_id"], name: "index_activity_coaches_on_coach_id"
  end

  create_table "activity_enrollments", force: :cascade do |t|
    t.bigint "student_id", null: false
    t.bigint "activity_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "present", default: false
    t.boolean "confirmed", default: false
    t.bigint "camp_enrollment_id"
    t.index ["activity_id"], name: "index_activity_enrollments_on_activity_id"
    t.index ["camp_enrollment_id"], name: "index_activity_enrollments_on_camp_enrollment_id"
    t.index ["student_id"], name: "index_activity_enrollments_on_student_id"
  end

  create_table "activity_stats", force: :cascade do |t|
    t.bigint "activity_id", null: false
    t.integer "students_count", default: 0
    t.integer "coaches_count", default: 0
    t.integer "number_of_boy", default: 0
    t.integer "number_of_girl", default: 0
    t.float "age_of_students", default: 0.0
    t.integer "absenteeism_rate", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "enrolled_students_count", default: 0
    t.index ["activity_id"], name: "index_activity_stats_on_activity_id"
  end

  create_table "annual_program_enrollments", force: :cascade do |t|
    t.bigint "student_id", null: false
    t.bigint "annual_program_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "present", default: false
    t.boolean "image_consent", default: true
    t.boolean "paid", default: false
    t.date "payment_date"
    t.string "payment_method"
    t.bigint "receiver_id"
    t.boolean "confirmed", default: false
    t.string "stripe_price_id"
    t.index ["annual_program_id"], name: "index_annual_program_enrollments_on_annual_program_id"
    t.index ["receiver_id"], name: "index_annual_program_enrollments_on_receiver_id"
    t.index ["student_id", "annual_program_id"], name: "index_annual_program_enrollments_on_student_and_program", unique: true
    t.index ["student_id"], name: "index_annual_program_enrollments_on_student_id"
  end

  create_table "annual_program_stats", force: :cascade do |t|
    t.bigint "annual_program_id", null: false
    t.integer "students_count", default: 0
    t.integer "show_count", default: 0
    t.integer "no_show_count", default: 0
    t.integer "show_rate", default: 0
    t.integer "no_show_rate", default: 0
    t.integer "absenteeism_rate", default: 0
    t.integer "percentage_of_boy", default: 0
    t.integer "percentage_of_girl", default: 0
    t.integer "coaches_count", default: 0
    t.integer "age_of_students", default: 0
    t.integer "category_ids", default: [], array: true
    t.jsonb "percentage_of_boy_by_category", default: {}
    t.jsonb "percentage_of_girl_by_category", default: {}
    t.jsonb "absenteisme_rate_by_category", default: {}
    t.jsonb "number_of_coaches_by_category", default: {}
    t.jsonb "students_count_by_category", default: {}
    t.integer "participant_ages", default: [], array: true
    t.jsonb "student_count_by_age", default: {}
    t.integer "participant_departments", default: [], array: true
    t.jsonb "student_count_by_department", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "enrolled_students_count_by_category", default: {}
    t.index ["annual_program_id"], name: "index_annual_program_stats_on_annual_program_id"
  end

  create_table "annual_programs", force: :cascade do |t|
    t.bigint "academy_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "starts_at"
    t.date "ends_at"
    t.boolean "new", default: true
    t.boolean "paid", default: true
    t.integer "price", default: 0
    t.integer "capacity"
    t.string "stripe_price_id"
    t.index ["academy_id"], name: "index_annual_programs_on_academy_id"
  end

  create_table "camp_deposits", force: :cascade do |t|
    t.bigint "manager_id", null: false
    t.bigint "depositor_id", null: false
    t.bigint "camp_id", null: false
    t.integer "cash_amount"
    t.integer "cheque_amount"
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["camp_id"], name: "index_camp_deposits_on_camp_id"
    t.index ["depositor_id"], name: "index_camp_deposits_on_depositor_id"
    t.index ["manager_id"], name: "index_camp_deposits_on_manager_id"
  end

  create_table "camp_enrollments", force: :cascade do |t|
    t.bigint "student_id", null: false
    t.bigint "camp_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "paid", default: false
    t.boolean "banished", default: false
    t.integer "number_of_absences", default: 0
    t.datetime "banishment_day"
    t.boolean "present", default: false
    t.boolean "image_consent", default: true
    t.date "payment_date"
    t.string "payment_method"
    t.bigint "receiver_id"
    t.string "stripe_price_id"
    t.boolean "on_waitlist", default: false
    t.boolean "confirmed", default: false
    t.bigint "school_period_enrollment_id"
    t.index ["camp_id"], name: "index_camp_enrollments_on_camp_id"
    t.index ["receiver_id"], name: "index_camp_enrollments_on_receiver_id"
    t.index ["school_period_enrollment_id"], name: "index_camp_enrollments_on_school_period_enrollment_id"
    t.index ["student_id"], name: "index_camp_enrollments_on_student_id"
  end

  create_table "camp_stats", force: :cascade do |t|
    t.bigint "camp_id", null: false
    t.integer "show_count", default: 0
    t.integer "no_show_count", default: 0
    t.integer "show_rate", default: 0
    t.integer "no_show_rate", default: 0
    t.integer "absenteeism_rate", default: 0
    t.integer "percentage_of_boy", default: 0
    t.integer "percentage_of_girl", default: 0
    t.float "age_of_students", default: 0.0
    t.integer "participant_ages", default: [], array: true
    t.jsonb "student_count_by_age", default: {}
    t.integer "participant_departments", default: [], array: true
    t.jsonb "student_count_by_department", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "students_count"
    t.integer "coaches_count"
    t.integer "new_students_count", default: 0
    t.integer "new_students_rate", default: 0
    t.index ["camp_id"], name: "index_camp_stats_on_camp_id"
  end

  create_table "camps", force: :cascade do |t|
    t.string "name"
    t.date "starts_at"
    t.date "ends_at"
    t.bigint "school_period_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "new", default: true
    t.string "stripe_price_id"
    t.integer "capacity"
    t.integer "waitlist_capacity", default: 5
    t.integer "price", default: 0, null: false
    t.index ["school_period_id"], name: "index_camps_on_school_period_id"
  end

  create_table "cart_items", force: :cascade do |t|
    t.decimal "price"
    t.bigint "cart_id", null: false
    t.bigint "student_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "product_type", null: false
    t.bigint "product_id", null: false
    t.string "stripe_price_id"
    t.boolean "paid", default: false
    t.string "name", null: false
    t.string "payment_method", default: "Carte bancaire"
    t.index ["cart_id"], name: "index_cart_items_on_cart_id"
    t.index ["product_type", "product_id"], name: "index_cart_items_on_product"
    t.index ["student_id"], name: "index_cart_items_on_student_id"
  end

  create_table "carts", force: :cascade do |t|
    t.string "status", default: "pending", null: false
    t.decimal "total_price"
    t.string "stripe_payment_intent_id"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_carts_on_user_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "super_category"
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

  create_table "coach_feedbacks", force: :cascade do |t|
    t.text "content"
    t.bigint "coach_id", null: false
    t.bigint "manager_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["coach_id"], name: "index_coach_feedbacks_on_coach_id"
    t.index ["manager_id"], name: "index_coach_feedbacks_on_manager_id"
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
    t.boolean "annual", default: false, null: false
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

  create_table "membership_deposits", force: :cascade do |t|
    t.bigint "manager_id", null: false
    t.bigint "depositor_id", null: false
    t.integer "cash_amount"
    t.integer "cheque_amount"
    t.date "date"
    t.integer "start_year"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["depositor_id"], name: "index_membership_deposits_on_depositor_id"
    t.index ["manager_id"], name: "index_membership_deposits_on_manager_id"
  end

  create_table "memberships", force: :cascade do |t|
    t.bigint "student_id", null: false
    t.boolean "paid", default: false
    t.integer "start_year"
    t.integer "amount"
    t.string "payment_method"
    t.date "payment_date"
    t.bigint "receiver_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "academy_id"
    t.string "stripe_price_id"
    t.index ["receiver_id"], name: "index_memberships_on_receiver_id"
    t.index ["student_id"], name: "index_memberships_on_student_id"
  end

  create_table "old_camp_deposits", force: :cascade do |t|
    t.bigint "manager_id", null: false
    t.bigint "camp_id", null: false
    t.integer "amount"
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["camp_id"], name: "index_old_camp_deposits_on_camp_id"
    t.index ["manager_id"], name: "index_old_camp_deposits_on_manager_id"
  end

  create_table "parent_profiles", force: :cascade do |t|
    t.string "gender"
    t.string "relationship_to_child"
    t.string "phone_number"
    t.string "address"
    t.string "zipcode"
    t.string "city"
    t.boolean "has_valid_rgpd"
    t.boolean "has_newsletter"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.string "stripe_customer_id"
    t.index ["user_id"], name: "index_parent_profiles_on_user_id"
  end

  create_table "program_periods", force: :cascade do |t|
    t.date "start_date"
    t.date "end_date"
    t.bigint "annual_program_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["annual_program_id"], name: "index_program_periods_on_annual_program_id"
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
    t.boolean "present", default: false
    t.boolean "tshirt_delivered", default: false
    t.index ["school_period_id"], name: "index_school_period_enrollments_on_school_period_id"
    t.index ["student_id"], name: "index_school_period_enrollments_on_student_id"
  end

  create_table "school_period_stats", force: :cascade do |t|
    t.bigint "school_period_id", null: false
    t.integer "students_count", default: 0
    t.integer "show_count", default: 0
    t.integer "no_show_count", default: 0
    t.integer "show_rate", default: 0
    t.integer "no_show_rate", default: 0
    t.integer "absenteeism_rate", default: 0
    t.integer "percentage_of_boy", default: 0
    t.integer "percentage_of_girl", default: 0
    t.integer "coaches_count", default: 0
    t.float "age_of_students", default: 0.0
    t.integer "category_ids", default: [], array: true
    t.jsonb "percentage_of_boy_by_category", default: {}
    t.jsonb "percentage_of_girl_by_category", default: {}
    t.jsonb "absenteisme_rate_by_category", default: {}
    t.jsonb "number_of_coaches_by_category", default: {}
    t.integer "participant_ages", default: [], array: true
    t.jsonb "student_count_by_age", default: {}
    t.integer "participant_departments", default: [], array: true
    t.jsonb "student_count_by_department", default: {}
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "students_count_by_category", default: {}
    t.integer "new_students_count", default: 0
    t.jsonb "enrolled_students_count_by_category", default: {}
    t.index ["school_period_id"], name: "index_school_period_stats_on_school_period_id"
  end

  create_table "school_periods", force: :cascade do |t|
    t.string "name"
    t.bigint "academy_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "year"
    t.boolean "paid", default: false
    t.integer "price", default: 0, null: false
    t.boolean "new", default: true
    t.boolean "tshirt", default: false
    t.boolean "free_judo", default: false
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
    t.string "allergy"
    t.integer "number_of_tshirts", default: 0
    t.bigint "user_id"
    t.integer "siblings_count", default: 0, null: false
    t.string "school"
    t.boolean "has_medical_treatment", default: false, null: false
    t.text "medical_treatment_description"
    t.boolean "photo_authorization", default: false, null: false
    t.boolean "rules_signed", default: false, null: false
    t.boolean "has_consent_for_photos", default: false
    t.index ["user_id"], name: "index_students_on_user_id"
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
    t.boolean "admin", default: false, null: false
    t.string "gender"
    t.string "address"
    t.string "zipcode"
    t.string "city"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "academies", "users", column: "coordinator_id"
  add_foreign_key "academies", "users", column: "manager_id"
  add_foreign_key "academy_enrollments", "academies"
  add_foreign_key "academy_enrollments", "students"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "activities", "annual_programs"
  add_foreign_key "activities", "camps"
  add_foreign_key "activities", "categories"
  add_foreign_key "activities", "locations"
  add_foreign_key "activities", "users", column: "coach_id"
  add_foreign_key "activity_coaches", "activities"
  add_foreign_key "activity_coaches", "users", column: "coach_id"
  add_foreign_key "activity_enrollments", "activities"
  add_foreign_key "activity_enrollments", "camp_enrollments"
  add_foreign_key "activity_enrollments", "students"
  add_foreign_key "activity_stats", "activities"
  add_foreign_key "annual_program_enrollments", "annual_programs"
  add_foreign_key "annual_program_enrollments", "students"
  add_foreign_key "annual_program_enrollments", "users", column: "receiver_id"
  add_foreign_key "annual_program_stats", "annual_programs"
  add_foreign_key "annual_programs", "academies"
  add_foreign_key "camp_deposits", "camps"
  add_foreign_key "camp_deposits", "users", column: "depositor_id"
  add_foreign_key "camp_deposits", "users", column: "manager_id"
  add_foreign_key "camp_enrollments", "camps"
  add_foreign_key "camp_enrollments", "school_period_enrollments"
  add_foreign_key "camp_enrollments", "students"
  add_foreign_key "camp_enrollments", "users", column: "receiver_id"
  add_foreign_key "camp_stats", "camps"
  add_foreign_key "camps", "school_periods"
  add_foreign_key "cart_items", "carts"
  add_foreign_key "cart_items", "students"
  add_foreign_key "carts", "users"
  add_foreign_key "coach_academies", "academies"
  add_foreign_key "coach_academies", "users", column: "coach_id"
  add_foreign_key "coach_camps", "camps"
  add_foreign_key "coach_camps", "users", column: "coach_id"
  add_foreign_key "coach_categories", "categories"
  add_foreign_key "coach_categories", "users", column: "coach_id"
  add_foreign_key "coach_feedbacks", "users", column: "coach_id"
  add_foreign_key "coach_feedbacks", "users", column: "manager_id"
  add_foreign_key "course_enrollments", "courses"
  add_foreign_key "course_enrollments", "students"
  add_foreign_key "courses", "activities"
  add_foreign_key "courses", "users", column: "coach_id"
  add_foreign_key "courses", "users", column: "manager_id"
  add_foreign_key "days", "activities"
  add_foreign_key "feedbacks", "students"
  add_foreign_key "feedbacks", "users", column: "coach_id"
  add_foreign_key "locations", "academies"
  add_foreign_key "membership_deposits", "users", column: "depositor_id"
  add_foreign_key "membership_deposits", "users", column: "manager_id"
  add_foreign_key "memberships", "students"
  add_foreign_key "memberships", "users", column: "receiver_id"
  add_foreign_key "old_camp_deposits", "camps"
  add_foreign_key "old_camp_deposits", "users", column: "manager_id"
  add_foreign_key "parent_profiles", "users"
  add_foreign_key "program_periods", "annual_programs"
  add_foreign_key "school_period_enrollments", "school_periods"
  add_foreign_key "school_period_enrollments", "students"
  add_foreign_key "school_period_stats", "school_periods"
  add_foreign_key "school_periods", "academies"
  add_foreign_key "students", "users"
  add_foreign_key "user_roles", "roles"
  add_foreign_key "user_roles", "users"
end
