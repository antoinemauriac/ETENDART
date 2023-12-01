class ChangeAgeTypeToActivityStat < ActiveRecord::Migration[7.0]
  def change
    change_column :activity_stats, :age_of_students, :float
  end
end
