class CreateCarts < ActiveRecord::Migration[7.0]
  def change
    create_table :carts do |t|
      t.string :status, default: 'pending', null: false
      t.decimal :total_price
      t.string :stripe_payment_intent_id
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
