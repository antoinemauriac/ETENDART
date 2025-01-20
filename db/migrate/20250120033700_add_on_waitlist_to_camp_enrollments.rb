class AddOnWaitlistToCampEnrollments < ActiveRecord::Migration[7.0]
  def change
    add_column :camp_enrollments, :on_waitlist, :boolean, default: false
  end
end
