class AddTshirtDeliveredToSchoolPeriodEnrollments < ActiveRecord::Migration[7.0]
  def change
    add_column :school_period_enrollments, :tshirt_delivered, :boolean, default: false
  end
end
