class RenameProductsColumnsInCartItems < ActiveRecord::Migration[7.0]
  def change
    rename_column :cart_items, :products_type, :product_type
    rename_column :cart_items, :products_id, :product_id
  end
end
