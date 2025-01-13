class ForceRemoveProductsColumnsFromCartItems < ActiveRecord::Migration[7.0]
  def up
    # Supprimer les colonnes si elles existent
    remove_column :cart_items, :products_id, :bigint if column_exists?(:cart_items, :products_id)
    remove_column :cart_items, :products_type, :string if column_exists?(:cart_items, :products_type)
  end

  def down
    # Recréer les colonnes en cas de rollback
    add_column :cart_items, :products_id, :bigint
    add_column :cart_items, :products_type, :string
  end
end
