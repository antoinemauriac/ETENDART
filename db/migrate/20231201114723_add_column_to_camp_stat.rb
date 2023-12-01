class AddColumnToCampStat < ActiveRecord::Migration[7.0]
  def change
    add_column :camp_stats, :students_count, :integer
    add_column :camp_stats, :coaches_count, :integer
    change_column :camp_stats, :age_of_students, :float
  end
end
