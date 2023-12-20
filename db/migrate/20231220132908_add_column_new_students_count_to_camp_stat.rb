class AddColumnNewStudentsCountToCampStat < ActiveRecord::Migration[7.0]
  def change
    add_column :camp_stats, :new_students_count, :integer, default: 0
    add_column :camp_stats, :new_students_rate, :integer, default: 0
    add_column :school_period_stats, :new_students_count, :integer, default: 0
  end
end
