class AddNumberOfAbsencesToCampEnrollments < ActiveRecord::Migration[7.0]
  def change
    add_column :camp_enrollments, :number_of_absences, :integer, default: 0
  end
end
