class CreateCampDeposits < ActiveRecord::Migration[7.0]
  def change
    create_table :camp_deposits do |t|
      t.references :manager, null: false, foreign_key: { to_table: :users }
      t.references :camp, null: false, foreign_key: true
      t.integer :amount
      t.date :date

      t.timestamps
    end
  end
end
