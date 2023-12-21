class AddEnrolledColumnToStats < ActiveRecord::Migration[7.0]
  def change
    add_column :annual_program_stats, :enrolled_students_count_by_category, :jsonb, default: {}
    add_column :school_period_stats, :enrolled_students_count_by_category, :jsonb, default: {}
    add_column :activity_stats, :enrolled_students_count, :integer, default: 0
  end
end
