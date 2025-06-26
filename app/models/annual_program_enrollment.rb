class AnnualProgramEnrollment < ApplicationRecord
  belongs_to :student
  belongs_to :annual_program
  has_one :academy, through: :annual_program
  belongs_to :receiver, class_name: 'User', foreign_key: :receiver_id, optional: true

  PAYMENT_METHODS = ["cash", "cheque", "hello_asso", "pass", "virement", "offert", nil].freeze
  validates :payment_method, inclusion: { in: PAYMENT_METHODS }
  validate :receiver_presence_for_specific_payment_methods

  scope :attended, -> { where(present: true) }
  scope :unattended, -> { where(present: false) }
  scope :paid, -> { where(paid: true) }
  scope :unpaid, -> { where(paid: false) }

  def paid!
    self.update!(paid: true, payment_date: Date.current)
  end

  private

  def receiver_presence_for_specific_payment_methods
    if ["cash", "cheque", "offert"].include?(payment_method) && receiver_id.blank?
      errors.add(:base, "Pour le paiement en espèces, chèque ou offert, vous devez préciser la personne ayant reçu le paiement.")
    end
  end
end
