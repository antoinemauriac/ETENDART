class ActivityEnrollment < ApplicationRecord
  # permet d'envoyer un params lors de l'inscription a une activité pour l'envoyer au camp_enrollment
  attr_accessor :payment_method

  belongs_to :student
  belongs_to :activity
  has_one :camp, through: :activity

  scope :attended, -> { where(present: true) }
  scope :unattended, -> { where(present: false) }

  # after_create -> { create_camp_enrollment(self.student) }

  # after_destroy -> { destroy_camp_enrollment(self.student) }

  # l'inscription à une activité doit créer un camp_enrollment et un cart_item
  def create_camp_enrollment(student)
    unless student.is_enrolled_in_camp?(self.camp)
      camp_enrollment_attributes = {
        student_id: student.id,
        camp_id: self.camp.id,
        stripe_price_id: self.camp.stripe_price_id
      }

      # Ajouter le payment_method seulement si c'est "carte bancaire"
      if self.payment_method == "virement"
        camp_enrollment_attributes[:payment_method] = self.payment_method
      end

      camp_enrollment = CampEnrollment.new(camp_enrollment_attributes)
      camp_enrollment.save!
    end
  end

  # Retrouver les enfants d'un parent qui sont inscrits à une activité
  def self.find_children_activity_enrollments(parent)
    joins(:student).where(students: { user_id: parent.id })
  end

  # Retrouver les enfants

  # def destroy_camp_enrollment(student)
  #   camp_enrollment = self.student.camp_enrollments.find_by(camp: self.camp)
  #   if self.student.is_enrolled_in_other_activities?(activity)
  #     self.destroy
  #   elsif camp_enrollment
  #     cart_item = camp_enrollment.cart_item
  #     camp_enrollment.destroy
  #     if cart_item && !cart_item.paid?
  #       cart_item.destroy
  #     end
  #   end
  # end

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
