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

      if item.product_type == 'CampEnrollment'
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
      elsif item.product_type == 'AnnualProgramEnrollment'
        annual_program = item.product.annual_program
        activities = student.activities.joins(:activity_enrollments).where(annual_program: annual_program, activity_enrollments: { confirmed: true }).distinct

        hash[student.full_name] ||= []
        hash[student.full_name] << {
          program_name: annual_program.name,
          program_dates: "#{annual_program.starts_at.strftime('%d/%m/%Y')} - #{annual_program.ends_at.strftime('%d/%m/%Y')}",
          program_price: item.price,
          paid: item.product.paid,
          activities: activities.map { |activity| { name: activity.name, hour_range: activity.hour_range, location: activity&.location&.address, category: activity.category.super_category } }
        }
      end
    end
  end
end
