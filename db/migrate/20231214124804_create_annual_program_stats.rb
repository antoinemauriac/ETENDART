class CreateAnnualProgramStats < ActiveRecord::Migration[7.0]
  def change
    create_table :annual_program_stats do |t|
      t.references :annual_program, null: false, foreign_key: true

      t.integer :students_count, default: 0
      t.integer :show_count, default: 0
      t.integer :no_show_count, default: 0
      t.integer :show_rate, default: 0
      t.integer :no_show_rate, default: 0
      t.integer :absenteeism_rate, default: 0
      t.integer :percentage_of_boy, default: 0
      t.integer :percentage_of_girl, default: 0

      t.integer :coaches_count, default: 0

      t.integer :age_of_students, default: 0

      t.integer :category_ids, array: true, default: []
      t.jsonb :percentage_of_boy_by_category, default: {}
      t.jsonb :percentage_of_girl_by_category, default: {}
      t.jsonb :absenteisme_rate_by_category, default: {}
      t.jsonb :number_of_coaches_by_category, default: {}

      t.jsonb :students_count_by_category, default: {}

      t.integer :participant_ages, array: true, default: []
      t.jsonb :student_count_by_age, default: {}

      t.integer :participant_departments, array: true, default: []
      t.jsonb :student_count_by_department, default: {}

      t.timestamps
    end
  end
end
