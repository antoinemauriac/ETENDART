class RenameCampDepositsTable < ActiveRecord::Migration[7.0]
  def change
    rename_table :camp_deposits, :old_camp_deposits
  end
end
