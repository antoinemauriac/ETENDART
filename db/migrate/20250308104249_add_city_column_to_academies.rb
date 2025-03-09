class AddCityColumnToAcademies < ActiveRecord::Migration[7.0]
  def change
    add_column :academies, :city, :string
  end
end
