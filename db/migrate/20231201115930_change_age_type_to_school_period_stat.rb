class ChangeAgeTypeToSchoolPeriodStat < ActiveRecord::Migration[7.0]
  def change
    change_column :school_period_stats, :age_of_students, :float
  end
end
