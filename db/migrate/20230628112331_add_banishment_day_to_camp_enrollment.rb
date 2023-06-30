class AddBanishmentDayToCampEnrollment < ActiveRecord::Migration[7.0]
  def change
    add_column :camp_enrollments, :banishment_day, :datetime
  end
end
