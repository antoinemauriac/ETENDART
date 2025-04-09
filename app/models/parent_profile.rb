class ParentProfile < ApplicationRecord
  belongs_to :user

  validates :gender, inclusion: { in: %w(Homme Femme Autre) }, presence: true
  validates :relationship_to_child, presence: true, inclusion: { in: %w(Père Mère Tuteur Autre) }
  validates :phone_number, presence: true # format: { with: /\A[0-9]+\z/ }
  validates :address, presence: true
  validates :zipcode, presence: true
  validates :city, presence: true
  validates :has_valid_rgpd, presence: true

  after_create :create_stripe_customer
  after_update :update_stripe_customer

  def create_stripe_customer
    stripe_customer = Stripe::Customer.create(
      address: {
        line1: self.address,
        postal_code: self.zipcode,
        city: self.city,
        country: 'FR',
        state: 'France'
      },
      email: self.user.email,
      name: self.user.full_name,
      phone: self.phone_number
    )
    self.update!(stripe_customer_id: stripe_customer.id)
  end

  def update_stripe_customer
    Stripe::Customer.update(self.stripe_customer_id,
      address: {
        line1: self.address,
        postal_code: self.zipcode,
        city: self.city,
        country: 'FR',
        state: 'France'
      },
      email: self.user.email,
      name: self.user.full_name,
      phone: self.phone_number
    )
  end

end
