require "administrate/base_dashboard"

class ParentProfileDashboard < Administrate::BaseDashboard
  # ATTRIBUTE_TYPES
  # a hash that describes the type of each of the model's fields.
  #
  # Each different type represents an Administrate::Field object,
  # which determines how the attribute is displayed
  # on pages throughout the dashboard.
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    address: Field::String,
    city: Field::String,
    zipcode: Field::String,
    gender: Field::String,
    has_newsletter: Field::Boolean,
    has_valid_rgpd: Field::Boolean,
    phone_number: Field::String,
    relationship_to_child: Field::String,
    stripe_customer_id: Field::String,
    user: Field::BelongsTo,
    created_at: Field::DateTime,
    updated_at: Field::DateTime,
  }.freeze

  # COLLECTION_ATTRIBUTES
  # an array of attributes that will be displayed on the model's index page.
  #
  # By default, it's limited to four items to reduce clutter on index pages.
  # Feel free to add, remove, or rearrange items.
  COLLECTION_ATTRIBUTES = %i[
    user
    stripe_customer_id
  ].freeze

  # SHOW_PAGE_ATTRIBUTES
  # an array of attributes that will be displayed on the model's show page.
  SHOW_PAGE_ATTRIBUTES = %i[
    id
    address
    city
    gender
    has_newsletter
    has_valid_rgpd
    phone_number
    relationship_to_child
    stripe_customer_id
    user
    zipcode
    created_at
    updated_at
  ].freeze

  # FORM_ATTRIBUTES
  # an array of attributes that will be displayed
  # on the model's form (`new` and `edit`) pages.
  FORM_ATTRIBUTES = %i[
    address
    city
    gender
    has_newsletter
    has_valid_rgpd
    phone_number
    relationship_to_child
    stripe_customer_id
    user
    zipcode
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

  # Overwrite this method to customize how parent profiles are displayed
  # across all pages of the admin dashboard.
  #
  # def display_resource(parent_profile)
  #   "ParentProfile ##{parent_profile.id}"
  # end
end
