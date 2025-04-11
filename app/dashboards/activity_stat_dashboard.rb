require "administrate/base_dashboard"

class ActivityStatDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    absenteeism_rate: Field::Number,
    activity: Field::BelongsTo,
    age_of_students: Field::Number.with_options(decimals: 2),
    coaches_count: Field::Number,
    enrolled_students_count: Field::Number,
    number_of_boy: Field::Number,
    number_of_girl: Field::Number,
    students_count: Field::Number,
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
    absenteeism_rate
    activity
    age_of_students
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    absenteeism_rate
    activity
    age_of_students
    coaches_count
    enrolled_students_count
    number_of_boy
    number_of_girl
    students_count
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    absenteeism_rate
    activity
    age_of_students
    coaches_count
    enrolled_students_count
    number_of_boy
    number_of_girl
    students_count
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

  # Overwrite this method to customize how activity stats are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(activity_stat)
  #   "ActivityStat ##{activity_stat.id}"
  # end
end
