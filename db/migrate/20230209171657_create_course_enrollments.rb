class CreateCourseEnrollments < ActiveRecord::Migration[7.0]
  def change
    create_table :course_enrollments do |t|
      t.references :student, null: false, foreign_key: true
      t.references :course, null: false, foreign_key: true
      t.boolean :present, default: true

      t.timestamps
    end
  end
end
