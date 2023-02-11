class AddYearToSchoolPeriods < ActiveRecord::Migration[7.0]
  def change
    add_column :school_periods, :year, :integer
  end
end
