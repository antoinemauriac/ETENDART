class RenameHasPaidColumnToCampEnrollments < ActiveRecord::Migration[7.0]
  def change
    rename_column :camp_enrollments, :has_paid, :paid
  end
end
