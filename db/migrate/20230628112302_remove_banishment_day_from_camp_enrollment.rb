class RemoveBanishmentDayFromCampEnrollment < ActiveRecord::Migration[7.0]
  def change
    remove_column :camp_enrollments, :banishment_day, :date
  end
end
