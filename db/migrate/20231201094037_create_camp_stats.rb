class CreateCampStats < ActiveRecord::Migration[7.0]
  def change
    create_table :camp_stats do |t|
      t.references :camp, null: false, foreign_key: true
      t.integer :show_count, default: 0
      t.integer :no_show_count, default: 0
      t.integer :show_rate, default: 0
      t.integer :no_show_rate, default: 0
      t.integer :absenteeism_rate, default: 0
      t.integer :percentage_of_boy, default: 0
      t.integer :percentage_of_girl, default: 0

      t.integer :age_of_students, default: 0

      t.integer :participant_ages, array: true, default: []
      t.jsonb :student_count_by_age, default: {}

      t.integer :participant_departments, array: true, default: []
      t.jsonb :student_count_by_department, default: {}

      t.timestamps
    end
  end
end
