class Commerce::Order < ApplicationRecord
  belongs_to :user, class_name: 'User'
  belongs_to :cart, class_name: 'Commerce::Cart'
end

# create_table "orders", force: :cascade do |t|
#   t.string "status", default: "paid", null: false
#   t.decimal "total_price", null: false
#   t.string "stripe_payment_intent_id", null: false
#   t.bigint "user_id", null: false
#   t.bigint "cart_id", null: false
#   t.datetime "created_at", null: false
#   t.datetime "updated_at", null: false
#   t.index ["cart_id"], name: "index_orders_on_cart_id"
#   t.index ["user_id"], name: "index_orders_on_user_id"
# end
