require "administrate/base_dashboard"

class StudentDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    academies: Field::HasMany,
    academy_enrollments: Field::HasMany,
    activities: Field::HasMany,
    activity_enrollments: Field::HasMany,
    address: Field::String,
    allergy: Field::String,
    annual_program_enrollments: Field::HasMany,
    annual_programs: Field::HasMany,
    camp_enrollments: Field::HasMany,
    camps: Field::HasMany,
    city: Field::String,
    course_enrollments: Field::HasMany,
    courses: Field::HasMany,
    date_of_birth: Field::Date,
    email: Field::String,
    feedbacks: Field::HasMany,
    first_name: Field::String,
    gender: Field::String,
    has_consent_for_photos: Field::Boolean,
    has_medical_treatment: Field::Boolean,
    last_name: Field::String,
    medical_treatment_description: Field::Text,
    memberships: Field::HasMany,
    number_of_tshirts: Field::Number,
    parent: Field::BelongsTo,
    phone_number: Field::String,
    photo_authorization: Field::Boolean,
    rules_signed: Field::Boolean,
    school: Field::String,
    school_period_enrollments: Field::HasMany,
    school_periods: Field::HasMany,
    siblings_count: Field::Number,
    user_id: Field::Number,
    username: Field::String,
    zipcode: Field::Number,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    id
    first_name
    last_name
    parent
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    academies
    academy_enrollments
    activities
    activity_enrollments
    address
    allergy
    annual_program_enrollments
    annual_programs
    camp_enrollments
    camps
    city
    course_enrollments
    courses
    date_of_birth
    email
    feedbacks
    first_name
    gender
    has_consent_for_photos
    has_medical_treatment
    last_name
    medical_treatment_description
    memberships
    number_of_tshirts
    parent
    phone_number
    photo_authorization
    rules_signed
    school
    school_period_enrollments
    school_periods
    siblings_count
    user_id
    username
    zipcode
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    academies
    academy_enrollments
    activities
    activity_enrollments
    address
    allergy
    annual_program_enrollments
    annual_programs
    camp_enrollments
    camps
    city
    course_enrollments
    courses
    date_of_birth
    email
    feedbacks
    first_name
    gender
    has_consent_for_photos
    has_medical_treatment
    last_name
    medical_treatment_description
    memberships
    number_of_tshirts
    parent
    phone_number
    photo_authorization
    rules_signed
    school
    school_period_enrollments
    school_periods
    siblings_count
    user_id
    username
    zipcode
  ].freeze

  # COLLECTION_FILTERS
  # a hash that defines filters that can be used while searching via the search
  # field of the dashboard.
  #
  # For example to add an option to search for open resources by typing "open:"
  # in the search field:
  #
  #   COLLECTION_FILTERS = {
  #     open: ->(resources) { resources.where(open: true) }
  #   }.freeze
  COLLECTION_FILTERS = {}.freeze

  # Overwrite this method to customize how students are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(student)
    "#{student.first_name} #{student.last_name}"
  end
end
