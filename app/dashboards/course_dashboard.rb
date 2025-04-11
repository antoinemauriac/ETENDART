require "administrate/base_dashboard"

class CourseDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    activity: Field::BelongsTo,
    annual: Field::Boolean,
    annual_program: Field::HasOne,
    camp: Field::HasOne,
    category: Field::HasOne,
    coach: Field::BelongsTo,
    course_enrollments: Field::HasMany,
    ends_at: Field::DateTime,
    manager: Field::BelongsTo,
    school_period: Field::HasOne,
    starts_at: Field::DateTime,
    status: Field::Boolean,
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
    activity
    annual
    annual_program
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    activity
    annual
    annual_program
    camp
    category
    coach
    course_enrollments
    ends_at
    manager
    school_period
    starts_at
    status
    students
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    activity
    annual
    annual_program
    camp
    category
    coach
    course_enrollments
    ends_at
    manager
    school_period
    starts_at
    status
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

  # Overwrite this method to customize how courses are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(course)
  #   "Course ##{course.id}"
  # end
end
