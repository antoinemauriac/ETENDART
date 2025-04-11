require "administrate/base_dashboard"

class SchoolPeriodDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    academy: Field::BelongsTo,
    activities: Field::HasMany,
    activity_enrollments: Field::HasMany,
    camp_deposits: Field::HasMany,
    camp_enrollments: Field::HasMany,
    camps: Field::HasMany,
    categories: Field::HasMany,
    coaches: Field::HasMany,
    course_enrollments: Field::HasMany,
    courses: Field::HasMany,
    free_judo: Field::Boolean,
    name: Field::String,
    new: Field::Boolean,
    old_camp_deposits: Field::HasMany,
    paid: Field::Boolean,
    price: Field::Number,
    school_period_enrollments: Field::HasMany,
    school_period_stat: Field::HasOne,
    students: Field::HasMany,
    tshirt: Field::Boolean,
    year: Field::Number,
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
    academy
    activities
    activity_enrollments
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    academy
    activities
    activity_enrollments
    camp_deposits
    camp_enrollments
    camps
    categories
    coaches
    course_enrollments
    courses
    free_judo
    name
    new
    old_camp_deposits
    paid
    price
    school_period_enrollments
    school_period_stat
    students
    tshirt
    year
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    academy
    activities
    activity_enrollments
    camp_deposits
    camp_enrollments
    camps
    categories
    coaches
    course_enrollments
    courses
    free_judo
    name
    new
    old_camp_deposits
    paid
    price
    school_period_enrollments
    school_period_stat
    students
    tshirt
    year
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

  # Overwrite this method to customize how school periods are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(school_period)
  #   "SchoolPeriod ##{school_period.id}"
  # end
end
