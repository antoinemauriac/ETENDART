class CreateAcademyEnrollments < ActiveRecord::Migration[7.0]
  def change
    create_table :academy_enrollments do |t|
      t.references :student, null: false, foreign_key: true
      t.references :academy, null: false, foreign_key: true

      t.timestamps
    end
  end
end
