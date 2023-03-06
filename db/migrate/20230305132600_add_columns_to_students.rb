class AddColumnsToStudents < ActiveRecord::Migration[7.0]
  def change
    add_column :students, :phone_number, :string
    add_column :students, :city, :string
    add_column :students, :zipcode, :integer
    remove_column :students, :parent_email, :string
  end
end
