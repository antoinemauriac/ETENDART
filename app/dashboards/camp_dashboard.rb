require "administrate/base_dashboard"

class CampDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    academy: Field::HasOne,
    activities: Field::HasMany,
    activity_coaches: Field::HasMany,
    activity_enrollments: Field::HasMany,
    camp_deposits: Field::HasMany,
    camp_enrollments: Field::HasMany,
    camp_stat: Field::HasOne,
    capacity: Field::Number,
    coach_camps: Field::HasMany,
    coaches: Field::HasMany,
    course_enrollments: Field::HasMany,
    courses: Field::HasMany,
    ends_at: Field::Date,
    name: Field::String,
    new: Field::Boolean,
    old_camp_deposits: Field::HasMany,
    school_period: Field::BelongsTo,
    starts_at: Field::Date,
    stripe_price_id: Field::String,
    students: Field::HasMany,
    waitlist_capacity: Field::Number,
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
    camp_deposits
    camp_enrollments
    camp_stat
    capacity
    coach_camps
    coaches
    course_enrollments
    courses
    ends_at
    name
    new
    old_camp_deposits
    school_period
    starts_at
    stripe_price_id
    students
    waitlist_capacity
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
    camp_deposits
    camp_enrollments
    camp_stat
    capacity
    coach_camps
    coaches
    course_enrollments
    courses
    ends_at
    name
    new
    old_camp_deposits
    school_period
    starts_at
    stripe_price_id
    students
    waitlist_capacity
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

  # Overwrite this method to customize how camps are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(camp)
    "Camp ##{camp.id} / #{camp.name} - #{camp.academy.name} - #{camp.school_period.name} "
  end
end
