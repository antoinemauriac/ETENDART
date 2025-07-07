class Membership < ApplicationRecord
  belongs_to :student
  belongs_to :receiver, class_name: 'User', foreign_key: :receiver_id, optional: true
  belongs_to :academy, optional: true

  has_one :cart_item, as: :product, class_name: 'Commerce::CartItem', dependent: :destroy

  PAYMENT_METHODS = ["cash", "cheque", "hello_asso", "pass", "virement", "offert", "financed", "offert_next_year", nil].freeze
  PAYMENT_METHODS_WITH_RECEIVER = ["cash", "cheque", "offert"].freeze
  PRICE = 15

  validates :payment_method, inclusion: { in: PAYMENT_METHODS }
  # un validate qui vérifie que le student n'a pas déjà une membership pour l'année en cours
  validates :student_id, uniqueness: { scope: :start_year, message: "Vous avez déjà payé votre cotisation pour cette année." }

  scope :paid, -> { where(paid: true) }
  scope :unpaid, -> { where(paid: false) }

  after_save :generate_offered_membership, if: -> { saved_change_to_paid? && paid && payment_method != "offert" }

  def generate_offered_membership
    return unless Date.current.between?(Date.new(Date.current.year, 5, 15), Date.new(Date.current.year, 8, 31))

    next_year_membership = student.memberships.find_by(start_year: start_year + 1)
    return if next_year_membership && next_year_membership.paid == true
    return if start_year == Date.current.year

    if next_year_membership
      next_year_membership.update!(
        paid: true,
        amount: PRICE,
        payment_method: "offert_next_year",
        payment_date: Date.current
      )
    else
      Membership.create!(
        student: student,
        start_year: start_year + 1,
        paid: true,
        amount: PRICE,
        payment_method: "offert_next_year",
        payment_date: Date.current
      )
    end
  end
  # MÉTHODE QUI RENVOIE LES MEMBERSHIPS A PRIORI NON EXIGIBLES
  def self.with_all_course_enrollments_present_false
    joins(student: { course_enrollments: :course })
      .where('courses.ends_at BETWEEN ? AND ?', Date.new(2024, 4, 7), Date.current)
      .group('students.id', 'memberships.id')
      .having('bool_and(course_enrollments.present = false)')
      .pluck('students.id', 'memberships.id')
      .to_h
  end

  # cotisation payée ?
  def paid?
    paid
  end

  def paid!
    self.update!(paid: true, payment_date: Date.current, payment_method: 'virement')
  end
end
