class AddDeletedToActivityEnrollments < ActiveRecord::Migration[7.0]
  def change
    add_column :activity_enrollments, :deleted, :boolean, default: false
  end
end
