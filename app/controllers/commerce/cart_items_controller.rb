class Commerce::CartItemsController < ApplicationController

  def create
    @cart_item = Commerce::CartItem.new(cart_item_params)
    @cart_item.cart = Commerce::Cart.find(params[:cart_id])
    if @cart_item.save
      redirect_to commerce_cart_path(@cart_item.cart), notice: "L'article a bien été ajouté au panier"
    else
      redirect_back fallback_location: commerce_cart_path(@cart_item.cart), alert: "Erreur lors de l'ajout de l'article au panier"
    end
  end

  def destroy
    @cart_item = Commerce::CartItem.find(params[:id])
    @cart_item.destroy
    redirect_to commerce_cart_path(@cart_item.cart)
  end

  private

  def cart_item_params
    params.require(:commerce_cart_item).permit(:product, :price, :student_id)
  end
end
