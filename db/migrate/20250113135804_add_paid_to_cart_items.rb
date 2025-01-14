class AddPaidToCartItems < ActiveRecord::Migration[7.0]
  def change
    add_column :cart_items, :paid, :boolean, default: false
  end
end
