class AddConfirmedToCampEnrollmentsAndActivityEnrollments < ActiveRecord::Migration[7.0]
  def change
    add_column :camp_enrollments, :confirmed, :boolean, default: false
    add_column :activity_enrollments, :confirmed, :boolean, default: false
  end
end
