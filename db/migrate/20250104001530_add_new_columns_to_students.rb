class AddNewColumnsToStudents < ActiveRecord::Migration[7.0]
  def change
    add_column :students, :siblings_count, :integer, default: 0, null: false
    add_column :students, :school, :string
    add_column :students, :has_medical_treatment, :boolean, default: false, null: false
    add_column :students, :medical_treatment_description, :text
    add_column :students, :photo_authorization, :boolean, default: false, null: false
    add_column :students, :rules_signed, :boolean, default: false, null: false
  end
end
