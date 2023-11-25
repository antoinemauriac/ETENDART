class AddColumnToAnnualProgram < ActiveRecord::Migration[7.0]
  def change
    add_column :annual_programs, :starts_at, :date
    add_column :annual_programs, :ends_at, :date
  end
end
