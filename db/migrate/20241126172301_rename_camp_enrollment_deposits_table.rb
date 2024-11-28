class RenameCampEnrollmentDepositsTable < ActiveRecord::Migration[7.0]
  def change
    rename_table :camp_enrollment_deposits, :camp_deposits
  end
end
