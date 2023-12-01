class CreateActivityStats < ActiveRecord::Migration[7.0]
  def change
    create_table :activity_stats do |t|
      t.references :activity, null: false, foreign_key: true
      t.integer :students_count, default: 0
      t.integer :coaches_count, default: 0
      t.integer :number_of_boy, default: 0
      t.integer :number_of_girl, default: 0
      t.integer :age_of_students, default: 0
      t.integer :absenteeism_rate, default: 0

      t.timestamps
    end
  end
end
