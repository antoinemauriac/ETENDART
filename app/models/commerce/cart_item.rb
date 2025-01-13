class Commerce::CartItem < ApplicationRecord
  belongs_to :cart, class_name: 'Commerce::Cart'
  belongs_to :student, class_name: 'Student'
  belongs_to :product, polymorphic: true

  validates :price, presence: true

end


# create_table "cart_items", force: :cascade do |t|
#   t.bigint "cart_id", null: false
#   t.string "product"
#   t.decimal "price"
#   t.bigint "student_id", null: false
#   t.datetime "created_at", null: false
#   t.datetime "updated_at", null: false
#   t.string "products_type", null: false
#   t.bigint "products_id", null: false
#   t.string "stripe_price_id"
#   t.index ["cart_id"], name: "index_cart_items_on_cart_id"
#   t.index ["products_type", "products_id"], name: "index_cart_items_on_products"
#   t.index ["student_id"], name: "index_cart_items_on_student_id"
# end
