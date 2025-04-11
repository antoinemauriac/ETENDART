require "administrate/base_dashboard"

class CampEnrollmentDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    academy: Field::HasOne,
    banished: Field::Boolean,
    banishment_day: Field::DateTime,
    camp: Field::BelongsTo,
    cart_item: Field::HasOne,
    confirmed: Field::Boolean,
    image_consent: Field::Boolean,
    number_of_absences: Field::Number,
    on_waitlist: Field::Boolean,
    paid: Field::Boolean,
    payment_date: Field::Date,
    payment_method: Field::String,
    present: Field::Boolean,
    receiver: Field::BelongsTo,
    school_period: Field::HasOne,
    school_period_enrollment_id: Field::Number,
    stripe_price_id: Field::String,
    student: Field::BelongsTo,
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
    banished
    banishment_day
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    academy
    banished
    banishment_day
    camp
    cart_item
    confirmed
    image_consent
    number_of_absences
    on_waitlist
    paid
    payment_date
    payment_method
    present
    receiver
    school_period
    school_period_enrollment_id
    stripe_price_id
    student
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    academy
    banished
    banishment_day
    camp
    cart_item
    confirmed
    image_consent
    number_of_absences
    on_waitlist
    paid
    payment_date
    payment_method
    present
    receiver
    school_period
    school_period_enrollment_id
    stripe_price_id
    student
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

  # Overwrite this method to customize how camp enrollments are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(camp_enrollment)
  #   "CampEnrollment ##{camp_enrollment.id}"
  # end
end
