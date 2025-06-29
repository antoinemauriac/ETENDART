class AddCapacityToAnnualPrograms < ActiveRecord::Migration[7.0]
  def change
    add_column :annual_programs, :capacity, :integer
  end
end
