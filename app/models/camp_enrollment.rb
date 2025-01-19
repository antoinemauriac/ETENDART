class CampEnrollment < ApplicationRecord
  belongs_to :student
  belongs_to :camp
  has_one :school_period, through: :camp
  has_one :academy, through: :school_period
  belongs_to :receiver, class_name: 'User', foreign_key: :receiver_id, optional: true

  has_one :cart_item, as: :product, class_name: 'Commerce::CartItem', dependent: :destroy

  PAYMENT_METHODS = ["cash", "cheque", "hello_asso", "pass", "virement", "offert", "carte bancaire", nil].freeze
  validates :payment_method, inclusion: { in: Membership::PAYMENT_METHODS }
  validate :receiver_presence_for_specific_payment_methods

  scope :attended, -> { where(present: true) }
  scope :unattended, -> { where(present: false) }

  scope :banished, -> { where(banished: true) }

  scope :paid, -> { where(paid: true) }
  scope :unpaid, -> { where(paid: false) }

  # quand le parent inscrit son enfant à une activité, il l'inscrit également au stage et il doit le payer par carte si il a choisi cette option
  after_create :create_cart_item

  def camp_starts_at
    camp.starts_at
  end

  def create_cart_item
    if payment_method == "carte bancaire"
      cart_item = Commerce::CartItem.new(
        cart_id: student.parent.carts.current_cart_for(student.parent).id,
        student_id: student.id,
        product: self,
        price: school_period.price,
        stripe_price_id: stripe_price_id)
      cart_item.save!
    end
  end

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
