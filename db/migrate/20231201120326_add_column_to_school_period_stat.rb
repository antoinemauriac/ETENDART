class AddColumnToSchoolPeriodStat < ActiveRecord::Migration[7.0]
  def change
    add_column :school_period_stats, :students_count_by_category, :jsonb, default: {}
  end
end
