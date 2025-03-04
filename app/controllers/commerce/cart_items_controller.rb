class Commerce::CartItemsController < ApplicationController

  def create
    @cart_item = Commerce::CartItem.new(cart_item_params)
    @cart_item.cart = Commerce::Cart.find(params[:cart_id])
    if @cart_item.save
      redirect_to commerce_cart_path, notice: "L'article a bien été ajouté au panier"
    else
      redirect_back fallback_location: commerce_cart_path, alert: "Erreur lors de l'ajout de l'article au panier"
    end
  end

  def update
    authorize Commerce::CartItem
    @cart_item = Commerce::CartItem.find(params[:id])
    if @cart_item.update(cart_item_params)
      redirect_to commerce_cart_path, notice: "L'article a bien été modifié"
    else
      redirect_back fallback_location: commerce_cart_path, alert: "Erreur lors de la modification de l'article"
    end
  end

  def destroy
    authorize Commerce::CartItem
    @cart_item = Commerce::CartItem.find(params[:id])
    camp_enrollment = @cart_item.product if @cart_item.product_type == 'CampEnrollment'
    school_period_enrollment = camp_enrollment.school_period_enrollment if camp_enrollment
    @cart_item.destroy
    if camp_enrollment
      activities_enrollments = camp_enrollment.student.activity_enrollments.where(activity: camp_enrollment.camp.activities)
      camp_enrollment.destroy
      school_period_enrollment.destroy if school_period_enrollment.camp_enrollments.empty?
    end

    redirect_to commerce_cart_path, notice: "L'article a bien été supprimé. L'inscription au stage a également été annulée"
  end

  private

  def cart_item_params
    params.require(:commerce_cart_item).permit(:product, :price, :payment_method, :student_id)
  end
end
