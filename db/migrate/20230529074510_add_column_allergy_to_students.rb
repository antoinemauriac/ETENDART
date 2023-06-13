class AddColumnAllergyToStudents < ActiveRecord::Migration[7.0]
  def change
    add_column :students, :allergy, :string
  end
end
