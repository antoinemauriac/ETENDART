class Commerce::CartItem < ApplicationRecord
  belongs_to :cart, class_name: 'Commerce::Cart'
  belongs_to :student, class_name: 'Student'
  belongs_to :product, polymorphic: true, dependent: :destroy

  validates :price, presence: true

  # before_create :get_name
  after_create :update_cart_total_price

  after_destroy :update_cart_total_price

  def paid!
    self.update!(paid: true)
    self.product.paid!
  end

  # def get_name
  #   if self.product_type == 'Membership' # si c'est une adhésion
  #     self.name = "Adhésion #{self.product.start_year}/#{self.product.start_year + 1} - #{self.product.student.first_name} #{self.product.student.last_name}"
  #   else # si c'est une inscription à un stage
  #     self.name = "Inscription #{self.product.school_period.name}/#{self.product.camp.name}/#{self.product.academy.name} - #{self.product.student.first_name} #{self.product.student.last_name}"
  #   end
  #   byebug
  #   self.save
  # end

  def update_cart_total_price
    cart.update_total_price
  end

  def destroy_camp_enrollment
    if self.product_type == 'CampEnrollment'
      self.product.destroy
    end
  end

  def self.group_by_student(cart_items)
    cart_items.each_with_object({}) do |item, hash|
      student = item.student
      camp = item.product.camp
      activities = student.activities.joins(:activity_enrollments).where(camp: camp, activity_enrollments: { confirmed: true }).distinct
  
      hash[student.full_name] ||= []
      hash[student.full_name] << {
        camp_name: camp.full_name,
        camp_dates: camp.format_starts_at_ends_at,
        camp_price: item.price,
        paid: item.product.paid,
        activities: activities.map { |activity| { name: activity.name, hour_range: activity.hour_range, location: activity&.location&.address, category: activity.category.super_category } }
      }
    end
  end
end


# create_table "cart_items", force: :cascade do |t|
#   t.decimal "price"
#   t.bigint "cart_id", null: false
#   t.bigint "student_id", null: false
#   t.datetime "created_at", null: false
#   t.datetime "updated_at", null: false
#   t.string "stripe_price_id"
#   t.string "product_type", null: false
#   t.bigint "product_id", null: false
#   t.boolean "paid", default: false
#   t.string "name", null: false
#   t.index ["cart_id"], name: "index_cart_items_on_cart_id"
#   t.index ["product_type", "product_id"], name: "index_cart_items_on_product"
#   t.index ["student_id"], name: "index_cart_items_on_student_id"
# end
