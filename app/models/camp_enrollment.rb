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

  def create_school_period_enrollment
    student.school_periods << school_period unless student.school_periods.include?(school_period)
  end

  def destroy_school_period_enrollment
    camp_enrollments = student.camp_enrollments.where(camp: school_period.camps)
    if camp_enrollments.empty?
      student.school_period_enrollments.find_by(school_period: school_period).destroy
    end
  end

  private

  def receiver_presence_for_specific_payment_methods
    if ["cash", "cheque"].include?(payment_method) && receiver_id.blank?
      errors.add(:base, "Pour le paiement en espèces, chèque ou offert, vous devez préciser la personne ayant reçu le paiement.")
    end
  end
end
