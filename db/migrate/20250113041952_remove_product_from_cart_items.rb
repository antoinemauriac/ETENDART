class RemoveProductFromCartItems < ActiveRecord::Migration[7.0]
  def change
    remove_column :cart_items, :product, :string
  end
end
