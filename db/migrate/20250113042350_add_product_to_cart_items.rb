class AddProductToCartItems < ActiveRecord::Migration[7.0]
  def change
    add_reference :cart_items, :product, polymorphic: true, null: false
    rename_column :cart_items, :products_type, :product_type
    rename_column :cart_items, :products_id, :product_id
  end
end
