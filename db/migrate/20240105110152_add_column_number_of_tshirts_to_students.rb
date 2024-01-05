class AddColumnNumberOfTshirtsToStudents < ActiveRecord::Migration[7.0]
  def change
    add_column :students, :number_of_tshirts, :integer, default: 0
  end
end
