class CreateSchoolPeriodEnrollments < ActiveRecord::Migration[7.0]
  def change
    create_table :school_period_enrollments do |t|
      t.references :student, null: false, foreign_key: true
      t.references :school_period, null: false, foreign_key: true

      t.timestamps
    end
  end
end
