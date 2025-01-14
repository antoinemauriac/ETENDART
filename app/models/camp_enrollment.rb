class CampEnrollment < ApplicationRecord
  belongs_to :student
  belongs_to :camp
  has_one :school_period, through: :camp
  has_one :academy, through: :school_period
  belongs_to :receiver, class_name: 'User', foreign_key: :receiver_id, optional: true

  has_many :cart_items, as: :product, class_name: 'Commerce::CartItem'

  PAYMENT_METHODS = ["cash", "cheque", "hello_asso", "pass", "virement", "offert", nil].freeze
  validates :payment_method, inclusion: { in: Membership::PAYMENT_METHODS }
  validate :receiver_presence_for_specific_payment_methods

  scope :attended, -> { where(present: true) }
  scope :unattended, -> { where(present: false) }

  scope :banished, -> { where(banished: true) }

  scope :paid, -> { where(paid: true) }
  scope :unpaid, -> { where(paid: false) }

  def camp_starts_at
    camp.starts_at
  end


  private

  def receiver_presence_for_specific_payment_methods
    if ["cash", "cheque", "offert"].include?(payment_method) && receiver_id.blank?
      errors.add(:base, "Pour le paiement en espèces, chèque ou offert, vous devez préciser la personne ayant reçu le paiement.")
    end
  end

end

# create_table "camp_enrollments", force: :cascade do |t|
#   t.bigint "student_id", null: false
#   t.bigint "camp_id", null: false
#   t.datetime "created_at", null: false
#   t.datetime "updated_at", null: false
#   t.boolean "paid", default: false
#   t.boolean "banished", default: false
#   t.integer "number_of_absences", default: 0
#   t.datetime "banishment_day"
#   t.boolean "present", default: false
#   t.boolean "image_consent", default: true
#   t.date "payment_date"
#   t.string "payment_method"
#   t.bigint "receiver_id"
#   t.string "stripe_price_id"
#   t.index ["camp_id"], name: "index_camp_enrollments_on_camp_id"
#   t.index ["receiver_id"], name: "index_camp_enrollments_on_receiver_id"
#   t.index ["student_id"], name: "index_camp_enrollments_on_student_id"
# end
