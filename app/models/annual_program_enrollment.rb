class AnnualProgramEnrollment < ApplicationRecord
  belongs_to :student
  belongs_to :annual_program
  has_one :academy, through: :annual_program
  belongs_to :receiver, class_name: 'User', foreign_key: :receiver_id, optional: true

  has_one :cart_item, as: :product, class_name: 'Commerce::CartItem', dependent: :destroy

  PAYMENT_METHODS = ["cash", "cheque", "hello_asso", "pass", "virement", "offert", "financed", nil].freeze
  validates :payment_method, inclusion: { in: PAYMENT_METHODS }
  validate :receiver_presence_for_specific_payment_methods

  after_destroy :destroy_activity_enrollments

  scope :attended, -> { where(present: true) }
  scope :unattended, -> { where(present: false) }
  scope :paid, -> { where(paid: true) }
  scope :unpaid, -> { where(paid: false) }
  scope :confirmed, -> { where(confirmed: true) }

  def paid!
    self.update!(paid: true, payment_date: Date.current)
  end

  def price
    annual_program.price
  end

  def stripe_price_id
    annual_program.stripe_price_id
  end

  private

  def receiver_presence_for_specific_payment_methods
    if ["cash", "cheque", "offert"].include?(payment_method) && receiver_id.blank?
      errors.add(:base, "Pour le paiement en espèces, chèque ou offert, vous devez préciser la personne ayant reçu le paiement.")
    end
  end

  def destroy_activity_enrollments
    student.activity_enrollments.where(activity: annual_program.activities)&.destroy_all
  end
end
