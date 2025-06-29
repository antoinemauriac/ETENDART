class AddConfirmedToAnnualProgramEnrollments < ActiveRecord::Migration[7.0]
  def change
    add_column :annual_program_enrollments, :confirmed, :boolean, default: false
  end
end
