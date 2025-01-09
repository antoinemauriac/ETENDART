class Commerce::CartsController < ApplicationController

  # on veut afficher le panier actuel qui a un statut 'pending' pour le parent connecté
  # il ne peut y avoir qu'un seul panier 'pending' par parent
  def show
    @parent = current_user
    @cart = Commerce::Cart.current_cart_for(@parent)
    @cart_items = @cart.cart_items
  end

end
