class Commerce::Cart < ApplicationRecord
  belongs_to :parent, class_name: 'User', foreign_key: :user_id
  has_many :cart_items, class_name: 'Commerce::CartItem', dependent: :destroy

  validates :status, presence: true, inclusion: { in: %w(pending completed cancelled) }
  validates :total_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  # Un validate qui garantit que chaque user n'a qu'un seul panier en cours
  validates :parent, uniqueness: { scope: :status, conditions: -> { where(status: 'pending') } }

  # apres l'ajout ou la suppression d'un article dans le panier, on met à jour le prix total du panier

  def self.current_cart_for(parent)
    current_cart = find_by(parent: parent, status: 'pending')
    unless current_cart
      current_cart = create!(parent: parent, status: 'pending', total_price: 0)
    end
    return current_cart
  end

  # Quand un panier est payé avec succès, son statut devient 'completed', les articles du panier sont marqués comme payés.
  def update_total_price
    self.total_price = cart_items.sum('price')
    save!
  end

  def paid!
    update!(status: 'completed')
  end

  def paid?
    status == 'completed'
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
