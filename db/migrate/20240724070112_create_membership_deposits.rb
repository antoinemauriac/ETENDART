class CreateMembershipDeposits < ActiveRecord::Migration[7.0]
  def change
    create_table :membership_deposits do |t|
      t.references :manager, null: false, foreign_key: { to_table: :users }
      t.references :depositor, null: false, foreign_key: { to_table: :users }
      t.integer :cash_amount
      t.integer :cheque_amount
      t.date :date
      t.integer :start_year

      t.timestamps
    end
  end
end
