class AddPaymentMethodToCartItems < ActiveRecord::Migration[7.0]
  def change
    add_column :cart_items, :payment_method, :string, default: 'Carte bancaire'
  end
end
