class DestroyPastCartItemsJob < ApplicationJob
  queue_as :default

  def perform
    ActiveRecord::Base.transaction do
      Commerce::CartItem
            .where(product_type: "CampEnrollment", paid: false)
            .joins("INNER JOIN camp_enrollments ON camp_enrollments.id = cart_items.product_id")
            .joins("INNER JOIN camps ON camps.id = camp_enrollments.camp_id")
            .where(camp_enrollments: { confirmed: false })
            .where("camps.ends_at < ?", Time.current)
            .find_each(&:destroy)
    end
  end
end
