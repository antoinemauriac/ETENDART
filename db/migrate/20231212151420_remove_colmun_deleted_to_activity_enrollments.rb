class RemoveColmunDeletedToActivityEnrollments < ActiveRecord::Migration[7.0]
  def change
    remove_column :activity_enrollments, :deleted, :boolean
  end
end
