require "administrate/base_dashboard"

class AnnualProgramDashboard < Administrate::BaseDashboard
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
    activity_coaches: Field::HasMany,
    activity_enrollments: Field::HasMany,
    annual_program_enrollments: Field::HasMany,
    annual_program_stat: Field::HasOne,
    categories: Field::HasMany,
    coaches: Field::HasMany,
    course_enrollments: Field::HasMany,
    courses: Field::HasMany,
    ends_at: Field::Date,
    new: Field::Boolean,
    program_periods: Field::HasMany,
    starts_at: Field::Date,
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
    academy
    activities
    activity_coaches
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    academy
    activities
    activity_coaches
    activity_enrollments
    annual_program_enrollments
    annual_program_stat
    categories
    coaches
    course_enrollments
    courses
    ends_at
    new
    program_periods
    starts_at
    students
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    academy
    activities
    activity_coaches
    activity_enrollments
    annual_program_enrollments
    annual_program_stat
    categories
    coaches
    course_enrollments
    courses
    ends_at
    new
    program_periods
    starts_at
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

  # Overwrite this method to customize how annual programs are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(annual_program)
  #   "AnnualProgram ##{annual_program.id}"
  # end
end
