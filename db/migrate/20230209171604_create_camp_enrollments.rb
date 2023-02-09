class CreateCampEnrollments < ActiveRecord::Migration[7.0]
  def change
    create_table :camp_enrollments do |t|
      t.references :student, null: false, foreign_key: true
      t.references :camp, null: false, foreign_key: true

      t.timestamps
    end
  end
end
