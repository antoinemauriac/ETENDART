class AddNewFormatColumnToAcademies < ActiveRecord::Migration[7.0]
  def change
    add_column :academies, :new_format, :boolean, default: false, null: false
  end
end
