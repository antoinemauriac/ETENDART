class CreateMemberships < ActiveRecord::Migration[7.0]
  def change
    create_table :memberships do |t|
      t.references :student, null: false, foreign_key: true
      t.boolean :status, default: false
      t.integer :start_year
      t.integer :amount
      t.string :payment_method
      t.date :payment_date
      t.references :receiver, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
