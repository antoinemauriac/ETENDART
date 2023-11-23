class AddColmunToAnnualProgramEnrollments < ActiveRecord::Migration[7.0]
  def change
    add_column :annual_program_enrollments, :present, :boolean, default: false
  end
end
