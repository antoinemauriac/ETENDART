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

  # quand le parent inscrit son enfant à une activité, il l'inscrit également au stage et il doit le payer par carte si il a choisi cette option
  # after_create :create_cart_item
  # after_create :create_school_period_enrollment

  # after_destroy :destroy_school_period_enrollment

  def camp_starts_at
    camp.starts_at
  end

  def create_cart_item
      cart_item = Commerce::CartItem.new(
        cart_id: student.parent.pending_cart.id,
        student_id: student.id,
        product: self,
        price: school_period.price,
        stripe_price_id: stripe_price_id)
      raise "Erreur lors de la création du cart_item" unless cart_item.save
      cart_item.save!
  end

  def paid!
    self.update!(paid: true, payment_date: Date.current)
  end

  ##########################################################################################
  # ENROLLMENT
  ##########################################################################################

  # def create_school_period_enrollment
  #   unless student.is_enrolled_in_school_period?(self.school_period)
  #     school_period_enrollment = SchoolPeriodEnrollment.new(
  #       student_id: self.student.id,
  #       school_period_id: self.school_period.id,
  #     )
  #     school_period_enrollment.save!
  #   end
  # end

  def create_school_period_enrollment
    student.school_periods << school_period unless student.school_periods.include?(school_period)
  end


  # def destroy_school_period_enrollment
  #   if self.student.is_enrolled_in_other_camps?(self.camp)
  #     true
  #   else
  #     school_period_enrollment = self.student.school_period_enrollments.find_by(school_period: self.school_period)
  #     if school_period_enrollment
  #       school_period_enrollment.destroy
  #     end
  #   end
  # end

  def destroy_school_period_enrollment
    camp_enrollments = student.camp_enrollments.where(camp: school_period.camps)
    if camp_enrollments.empty?
      student.school_period_enrollments.find_by(school_period: school_period).destroy
    end
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
