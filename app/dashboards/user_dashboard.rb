require "administrate/base_dashboard"

class UserDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    academies_as_coach: Field::HasMany,
    academies_as_coordinator: Field::HasMany,
    academies_as_manager: Field::HasMany,
    activities: Field::HasMany,
    activity_coaches: Field::HasMany,
    admin: Field::Boolean,
    camp_deposits_as_depositor: Field::HasMany,
    camp_deposits_as_manager: Field::HasMany,
    camps: Field::HasMany,
    categories: Field::HasMany,
    children: Field::HasMany,
    coach_academies: Field::HasMany,
    coach_camps: Field::HasMany,
    coach_categories: Field::HasMany,
    coach_feedbacks: Field::HasMany,
    confirmation_sent_at: Field::DateTime,
    confirmation_token: Field::String,
    confirmed_at: Field::DateTime,
    course_enrollments: Field::HasMany,
    courses: Field::HasMany,
    courses_as_manager: Field::HasMany,
    email: Field::String,
    encrypted_password: Field::String,
    feedbacks: Field::HasMany,
    first_name: Field::String,
    gender: Field::String,
    last_name: Field::String,
    membership_deposits_as_depositor: Field::HasMany,
    membership_deposits_as_manager: Field::HasMany,
    memberships: Field::HasMany,
    old_camp_deposits: Field::HasMany,
    parent_profile: Field::HasOne,
    phone_number: Field::String,
    remember_created_at: Field::DateTime,
    reset_password_sent_at: Field::DateTime,
    reset_password_token: Field::String,
    roles: Field::HasMany,
    status: Field::String,
    students: Field::HasMany,
    unconfirmed_email: Field::String,
    user_roles: Field::HasMany,
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
    email
    first_name
    last_name
    children
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    academies_as_coach
    academies_as_coordinator
    academies_as_manager
    activities
    activity_coaches
    admin
    camp_deposits_as_depositor
    camp_deposits_as_manager
    camps
    categories
    children
    coach_academies
    coach_camps
    coach_categories
    coach_feedbacks
    confirmation_sent_at
    confirmation_token
    confirmed_at
    course_enrollments
    courses
    courses_as_manager
    email
    encrypted_password
    feedbacks
    first_name
    gender
    last_name
    membership_deposits_as_depositor
    membership_deposits_as_manager
    memberships
    old_camp_deposits
    parent_profile
    phone_number
    remember_created_at
    reset_password_sent_at
    reset_password_token
    roles
    status
    students
    unconfirmed_email
    user_roles
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    academies_as_coach
    academies_as_coordinator
    academies_as_manager
    activities
    activity_coaches
    admin
    camps
    categories
    children
    coach_academies
    coach_camps
    coach_categories
    coach_feedbacks
    confirmation_sent_at
    confirmation_token
    confirmed_at
    course_enrollments
    courses
    courses_as_manager
    email
    encrypted_password
    feedbacks
    first_name
    gender
    last_name
    membership_deposits_as_depositor
    membership_deposits_as_manager
    memberships
    parent_profile
    phone_number
    remember_created_at
    reset_password_sent_at
    reset_password_token
    roles
    status
    students
    unconfirmed_email
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

  # Overwrite this method to customize how users are displayed
  # across all pages of the admin dashboard.
  #
  def display_resource(user)
    "#{user.first_name} #{user.last_name} - #{user.email}"
  end
end
