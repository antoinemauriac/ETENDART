class CampEnrollment < ApplicationRecord
  belongs_to :student
  belongs_to :camp
  has_one :school_period, through: :camp
  has_one :academy, through: :school_period
  belongs_to :receiver, class_name: 'User', foreign_key: :receiver_id, optional: true

  has_one :cart_item, as: :product, class_name: 'Commerce::CartItem', dependent: :destroy

  PAYMENT_METHODS = ["cash", "cheque", "hello_asso", "pass", "virement", "offert", nil].freeze
  validates :payment_method, inclusion: { in: Membership::PAYMENT_METHODS }
  validate :receiver_presence_for_specific_payment_methods

  scope :attended, -> { where(present: true) }
  scope :unattended, -> { where(present: false) }

  scope :confirmed, -> { where(confirmed: true) }

  scope :banished, -> { where(banished: true) }

  scope :paid, -> { where(paid: true) }
  scope :unpaid, -> { where(paid: false) }

  def camp_starts_at
    camp.starts_at
  end

  def paid!
    self.update!(paid: true, payment_date: Date.current)
  end

  private

  def receiver_presence_for_specific_payment_methods
    if ["cash", "cheque"].include?(payment_method) && receiver_id.blank?
      errors.add(:base, "Pour le paiement en espèces, chèque ou offert, vous devez préciser la personne ayant reçu le paiement.")
    end
  end
end
