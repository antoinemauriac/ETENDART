class AddAnnualToCourses < ActiveRecord::Migration[7.0]
  def change
    add_column :courses, :annual, :boolean, default: false, null: false
  end
end
