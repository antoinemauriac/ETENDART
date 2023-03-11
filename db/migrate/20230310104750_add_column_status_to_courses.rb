class AddColumnStatusToCourses < ActiveRecord::Migration[7.0]
  def change
    add_column :courses, :status, :boolean, default: false
  end
end
