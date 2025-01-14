class Commerce::Cart < ApplicationRecord
  belongs_to :parent, class_name: 'User', foreign_key: :user_id
  has_many :cart_items, class_name: 'Commerce::CartItem', dependent: :destroy

  validates :status, presence: true, inclusion: { in: %w(pending completed cancelled) }
  validates :total_price, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # apres l'ajout ou la suppression d'un article dans le panier, on met à jour le prix total du panier

  def self.current_cart_for(parent)
    find_or_create_by(parent: parent, status: 'pending')
  end

  # Quand un panier est payé avec succès, son statut devient 'completed', les articles du panier sont marqués comme payés.
  def update_total_price
    self.total_price = cart_items.sum('price')
    save!
  end
end

# create_table "carts", force: :cascade do |t|
#   t.string "status"
#   t.decimal "total_price"
#   t.string "stripe_payment_intent_id"
#   t.bigint "user_id", null: false
#   t.datetime "created_at", null: false
#   t.datetime "updated_at", null: false
#   t.index ["user_id"], name: "index_carts_on_user_id"
# end
