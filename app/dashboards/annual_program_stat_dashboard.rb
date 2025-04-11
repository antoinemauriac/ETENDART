require "administrate/base_dashboard"

class AnnualProgramStatDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    absenteeism_rate: Field::Number,
    absenteisme_rate_by_category: Field::String.with_options(searchable: false),
    age_of_students: Field::Number,
    annual_program: Field::BelongsTo,
    category_ids: Field::Number,
    coaches_count: Field::Number,
    enrolled_students_count_by_category: Field::String.with_options(searchable: false),
    no_show_count: Field::Number,
    no_show_rate: Field::Number,
    number_of_coaches_by_category: Field::String.with_options(searchable: false),
    participant_ages: Field::Number,
    participant_departments: Field::Number,
    percentage_of_boy: Field::Number,
    percentage_of_boy_by_category: Field::String.with_options(searchable: false),
    percentage_of_girl: Field::Number,
    percentage_of_girl_by_category: Field::String.with_options(searchable: false),
    show_count: Field::Number,
    show_rate: Field::Number,
    student_count_by_age: Field::String.with_options(searchable: false),
    student_count_by_department: Field::String.with_options(searchable: false),
    students_count: Field::Number,
    students_count_by_category: Field::String.with_options(searchable: false),
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
    absenteisme_rate_by_category
    age_of_students
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    absenteeism_rate
    absenteisme_rate_by_category
    age_of_students
    annual_program
    category_ids
    coaches_count
    enrolled_students_count_by_category
    no_show_count
    no_show_rate
    number_of_coaches_by_category
    participant_ages
    participant_departments
    percentage_of_boy
    percentage_of_boy_by_category
    percentage_of_girl
    percentage_of_girl_by_category
    show_count
    show_rate
    student_count_by_age
    student_count_by_department
    students_count
    students_count_by_category
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    absenteeism_rate
    absenteisme_rate_by_category
    age_of_students
    annual_program
    category_ids
    coaches_count
    enrolled_students_count_by_category
    no_show_count
    no_show_rate
    number_of_coaches_by_category
    participant_ages
    participant_departments
    percentage_of_boy
    percentage_of_boy_by_category
    percentage_of_girl
    percentage_of_girl_by_category
    show_count
    show_rate
    student_count_by_age
    student_count_by_department
    students_count
    students_count_by_category
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

  # Overwrite this method to customize how annual program stats are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(annual_program_stat)
  #   "AnnualProgramStat ##{annual_program_stat.id}"
  # end
end
