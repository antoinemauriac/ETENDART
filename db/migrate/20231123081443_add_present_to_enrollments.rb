class AddPresentToEnrollments < ActiveRecord::Migration[7.0]
  def change
    add_column :activity_enrollments, :present, :boolean, default: false
    add_column :camp_enrollments, :present, :boolean, default: false
    add_column :school_period_enrollments, :present, :boolean, default: false
  end
end
