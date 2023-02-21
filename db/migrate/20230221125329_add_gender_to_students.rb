class AddGenderToStudents < ActiveRecord::Migration[7.0]
  def change
    add_column :students, :gender, :string
  end
end
