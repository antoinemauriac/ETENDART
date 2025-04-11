require "administrate/base_dashboard"

class AcademyDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    academy_enrollments: Field::HasMany,
    activities_through_annual_programs: Field::HasMany,
    activities_through_camps: Field::HasMany,
    annual: Field::Boolean,
    annual_programs: Field::HasMany,
    banished: Field::Boolean,
    camps: Field::HasMany,
    city: Field::String,
    coach_academies: Field::HasMany,
    coaches: Field::HasMany,
    coordinator: Field::BelongsTo,
    courses_through_annual_programs: Field::HasMany,
    courses_through_camps: Field::HasMany,
    image_attachment: Field::HasOne,
    image_blob: Field::HasOne,
    locations: Field::HasMany,
    manager: Field::BelongsTo,
    memberships: Field::HasMany,
    name: Field::String,
    new_format: Field::Boolean,
    school_periods: Field::HasMany,
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
    name
    city

  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    academy_enrollments
    activities_through_annual_programs
    activities_through_camps
    annual
    annual_programs
    banished
    camps
    city
    coach_academies
    coaches
    coordinator
    courses_through_annual_programs
    courses_through_camps
    locations
    manager
    memberships
    name
    new_format
    school_periods
    students
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    academy_enrollments
    activities_through_annual_programs
    activities_through_camps
    annual
    annual_programs
    banished
    camps
    city
    coach_academies
    coaches
    coordinator
    courses_through_annual_programs
    courses_through_camps
    locations
    manager
    memberships
    name
    new_format
    school_periods
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

  # Overwrite this method to customize how academies are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(academy)
  #   "Academy ##{academy.id}"
  # end
  def display_resource(academy)
    "#{academy.name} - #{academy.city}"
  end
end
