class Commerce::CartItem < ApplicationRecord
  belongs_to :cart, class_name: 'Commerce::Cart'
  belongs_to :student, class_name: 'Student'
end


# t.bigint "cart_id", null: false
# t.string "product"
# t.decimal "price"
# t.bigint "student_id", null: false
# t.datetime "created_at", null: false
# t.datetime "updated_at", null: false
# t.index ["cart_id"], name: "index_cart_items_on_cart_id"
# t.index ["student_id"], name: "index_cart_items_on_student_id"
