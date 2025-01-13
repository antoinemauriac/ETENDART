class AddPurchasableToCartItems < ActiveRecord::Migration[7.0]
  def change
    # Ajoute une relation polymorphique correcte pour 'product'
    add_reference :cart_items, :product, polymorphic: true, null: false

    # Ajoute les colonnes stripe_price_id pour les différentes tables
    add_column :cart_items, :stripe_price_id, :string
    add_column :memberships, :stripe_price_id, :string
    add_column :camp_enrollments, :stripe_price_id, :string
    add_column :camps, :stripe_price_id, :string
  end
end
