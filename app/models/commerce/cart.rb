class Commerce::Cart < ApplicationRecord
  belongs_to :parent, class_name: 'User', foreign_key: :user_id
  has_many :cart_items, class_name: 'Commerce::CartItem', dependent: :destroy

  validates :status, presence: true, inclusion: { in: %w(pending completed cancelled) }
  validates :total_price, presence: true, numericality: { greater_than_or_equal_to: 0 }
  # Un validate qui garantit que chaque user n'a qu'un seul panier en cours
  validates :parent, uniqueness: { scope: :status, conditions: -> { where(status: 'pending') } }

  # apres l'ajout ou la suppression d'un article dans le panier, on met à jour le prix total du panier


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