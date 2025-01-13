class RemoveProductsColumnsFromCartItems < ActiveRecord::Migration[7.0]
  def change
    remove_column :cart_items, :products_type, :string
    remove_column :cart_items, :products_id, :bigint
  end
end
