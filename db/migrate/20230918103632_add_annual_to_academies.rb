class AddAnnualToAcademies < ActiveRecord::Migration[7.0]
  def change
    add_column :academies, :annual, :boolean, default: false
  end
end
