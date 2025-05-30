class Membership < ApplicationRecord
  belongs_to :student
  belongs_to :receiver, class_name: 'User', foreign_key: :receiver_id, optional: true
  belongs_to :academy, optional: true

  has_one :cart_item, as: :product, class_name: 'Commerce::CartItem', dependent: :destroy

  PAYMENT_METHODS = ["cash", "cheque", "hello_asso", "pass", "virement", "offert", nil].freeze
  PAYMENT_METHODS_WITH_RECEIVER = ["cash", "cheque", "offert"].freeze
  PRICE = 15

  validates :payment_method, inclusion: { in: Membership::PAYMENT_METHODS }
  # un validate qui vérifie que le student n'a pas déjà une membership pour l'année en cours
  validates :student_id, uniqueness: { scope: :start_year, message: "Vous avez déjà payé votre cotisation pour cette année." }

  scope :paid, -> { where(paid: true) }
  scope :unpaid, -> { where(paid: false) }

  # after_update :get_payment_date, if: -> { saved_change_to_paid? && paid }

  # MÉTHODE QUI RENVOIE LES MEMBERSHIPS A PRIORI NON EXIGIBLES
  def self.with_all_course_enrollments_present_false
    joins(student: { course_enrollments: :course })
      .where('courses.ends_at BETWEEN ? AND ?', Date.new(2024, 4, 7), Date.current)
      .group('students.id', 'memberships.id')
      .having('bool_and(course_enrollments.present = false)')
      .pluck('students.id', 'memberships.id')
      .to_h
  end

  # Maintenant que les memberships ne sont payables que par carte, le payment date est la date au moment où paid est true
  def get_payment_date
    self.payment_date = Date.current
    self.save
  end

  # cotisation payée ?
  def paid?
    paid
  end

  def paid!
    self.update!(paid: true, payment_date: Date.current, payment_method: 'virement')
  end




  # SUPPRESSION DES MEMBERSHIPS A PRIORI NON EXIGIBLES SI L'ELEVE N'A PAS DE COURS FUTUR
  # Membership.with_all_course_enrollments_present_false.each do |student_id, membership_id|
  #   student = Student.find(student_id)
  #   membership = Membership.find(membership_id)
  #   if student.courses.where('starts_at > ?', Date.current).empty?
  #     membership.destroy²
  #   end
  # end
end

# create_table "memberships", force: :cascade do |t|
#   t.bigint "student_id", null: false
#   t.boolean "paid", default: false
#   t.integer "start_year"
#   t.integer "amount"
#   t.string "payment_method"
#   t.date "payment_date"
#   t.bigint "receiver_id"
#   t.datetime "created_at", null: false
#   t.datetime "updated_at", null: false
#   t.integer "academy_id"
#   t.string "stripe_price_id"
#   t.index ["receiver_id"], name: "index_memberships_on_receiver_id"
#   t.index ["student_id"], name: "index_memberships_on_student_id"
# end
