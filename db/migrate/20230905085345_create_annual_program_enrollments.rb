class CreateAnnualProgramEnrollments < ActiveRecord::Migration[7.0]
  def change
    create_table :annual_program_enrollments do |t|
      t.references :student, null: false, foreign_key: true
      t.references :annual_program, null: false, foreign_key: true

      t.timestamps
    end
  end
end
