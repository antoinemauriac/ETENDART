require "administrate/base_dashboard"

class ActivityDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    activity_coaches: Field::HasMany,
    activity_enrollments: Field::HasMany,
    activity_stat: Field::HasOne,
    age_restricted: Field::Boolean,
    annual: Field::Boolean,
    annual_program: Field::BelongsTo,
    camp: Field::BelongsTo,
    category: Field::BelongsTo,
    coach: Field::BelongsTo,
    coaches: Field::HasMany,
    course_enrollments: Field::HasMany,
    courses: Field::HasMany,
    location: Field::BelongsTo,
    max_age: Field::Number,
    min_age: Field::Number,
    name: Field::String,
    school_period: Field::HasOne,
    students: Field::HasMany,
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
    activity_coaches
    activity_enrollments
    activity_stat
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    activity_coaches
    activity_enrollments
    activity_stat
    age_restricted
    annual
    annual_program
    camp
    category
    coach
    coaches
    course_enrollments
    courses
    location
    max_age
    min_age
    name
    school_period
    students
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    activity_coaches
    activity_enrollments
    activity_stat
    age_restricted
    annual
    annual_program
    camp
    category
    coach
    coaches
    course_enrollments
    courses
    location
    max_age
    min_age
    name
    school_period
    students
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

  # Overwrite this method to customize how activities are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(activity)
    "Activity ##{activity.id} / #{activity.name} - #{activity.category.name}"
  end
end
