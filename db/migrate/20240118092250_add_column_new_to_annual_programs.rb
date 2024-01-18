class AddColumnNewToAnnualPrograms < ActiveRecord::Migration[7.0]
  def change
    add_column :annual_programs, :new, :boolean, default: true
  end
end
