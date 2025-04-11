require "administrate/base_dashboard"

class CampStatDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    absenteeism_rate: Field::Number,
    age_of_students: Field::Number.with_options(decimals: 2),
    camp: Field::BelongsTo,
    coaches_count: Field::Number,
    new_students_count: Field::Number,
    new_students_rate: Field::Number,
    no_show_count: Field::Number,
    no_show_rate: Field::Number,
    participant_ages: Field::Number,
    participant_departments: Field::Number,
    percentage_of_boy: Field::Number,
    percentage_of_girl: Field::Number,
    show_count: Field::Number,
    show_rate: Field::Number,
    student_count_by_age: Field::String.with_options(searchable: false),
    student_count_by_department: Field::String.with_options(searchable: false),
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
    age_of_students
    camp
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    absenteeism_rate
    age_of_students
    camp
    coaches_count
    new_students_count
    new_students_rate
    no_show_count
    no_show_rate
    participant_ages
    participant_departments
    percentage_of_boy
    percentage_of_girl
    show_count
    show_rate
    student_count_by_age
    student_count_by_department
    students_count
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    absenteeism_rate
    age_of_students
    camp
    coaches_count
    new_students_count
    new_students_rate
    no_show_count
    no_show_rate
    participant_ages
    participant_departments
    percentage_of_boy
    percentage_of_girl
    show_count
    show_rate
    student_count_by_age
    student_count_by_department
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

  # Overwrite this method to customize how camp stats are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(camp_stat)
  #   "CampStat ##{camp_stat.id}"
  # end
end
