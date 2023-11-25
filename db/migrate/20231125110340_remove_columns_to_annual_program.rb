class RemoveColumnsToAnnualProgram < ActiveRecord::Migration[7.0]
  def change
    remove_column :annual_programs, :start_year, :integer
    remove_column :annual_programs, :end_year, :integer
  end
end
