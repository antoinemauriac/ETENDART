class CreateActivityEnrollments < ActiveRecord::Migration[7.0]
  def change
    create_table :activity_enrollments do |t|
      t.references :student, null: false, foreign_key: true
      t.references :activity, null: false, foreign_key: true

      t.timestamps
    end
  end
end
