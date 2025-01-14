class ActivityEnrollment < ApplicationRecord
  belongs_to :student
  belongs_to :activity
  has_one :camp, through: :activity

  scope :attended, -> { where(present: true) }
  scope :unattended, -> { where(present: false) }

  after_create :create_camp_enrollment_and_cart_item

  # l'inscription à une activité doit créer un camp_enrollment et un cart_item
  def create_camp_enrollment_and_cart_item(student)
    unless student.is_enrolled_in_camp?(self.camp)
      camp_enrollment = CampEnrollment.new(
        student_id: student.id,
        camp_id: self.camp.id,
        stripe_price_id: self.camp.stripe_price_id)
      camp_enrollment.save!
      cart_item = Commerce::CartItem.new(
        cart_id: student.parent.carts.current_cart_for(student.parent).id,
        student_id: student.id,
        product: camp_enrollment,
        price: camp_enrollment.school_period.price,
        stripe_price_id: camp_enrollment.stripe_price_id)
      cart_item.save!
    end
  end
end


# create_table "activity_enrollments", force: :cascade do |t|
#   t.bigint "student_id", null: false
#   t.bigint "activity_id", null: false
#   t.datetime "created_at", null: false
#   t.datetime "updated_at", null: false
#   t.boolean "present", default: false
#   t.index ["activity_id"], name: "index_activity_enrollments_on_activity_id"
#   t.index ["student_id"], name: "index_activity_enrollments_on_student_id"
# end
