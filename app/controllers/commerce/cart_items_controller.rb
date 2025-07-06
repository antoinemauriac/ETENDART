class Commerce::CartItemsController < ApplicationController

  def create
    @cart_item = Commerce::CartItem.new(cart_item_params)
    @cart_item.cart = Commerce::Cart.find(params[:cart_id])
    if @cart_item.save
      redirect_to commerce_cart_path
    else
      redirect_back fallback_location: commerce_cart_path, alert: "Erreur lors de l'ajout de l'article au panier"
    end
  end

  def update
    authorize Commerce::CartItem
    @cart_item = Commerce::CartItem.find(params[:id])
    if @cart_item.update(cart_item_params)
      redirect_to commerce_cart_path
    else
      redirect_back fallback_location: commerce_cart_path, alert: "Erreur lors de la modification de l'article"
    end
  end

  def destroy
    authorize Commerce::CartItem
    cart_item = Commerce::CartItem.find(params[:id])

    case cart_item.product_type
    when 'CampEnrollment'
      handle_camp_enrollment_deletion(cart_item)
    when 'AnnualProgramEnrollment'
      handle_annual_program_enrollment_deletion(cart_item)
    else
      cart_item.destroy
    end

    redirect_to commerce_cart_path, notice: "L'inscription a été annulée"
  end

  private

  def handle_camp_enrollment_deletion(cart_item)
    student = cart_item.student
    camp_enrollment = cart_item.product
    cart_item.destroy
    camp_enrollment.destroy
    cleanup_membership(cart_item.cart, student)
  end

  def handle_annual_program_enrollment_deletion(cart_item)
    student = cart_item.student
    annual_program_enrollment = cart_item.product
    cart_item.destroy
    annual_program_enrollment.destroy
    cleanup_membership(cart_item.cart, student)
  end

  def cleanup_membership(cart, student)
    student_items = cart.cart_items.where(student: student)
    membership_items = cart.cart_items.where(product_type: 'Membership', student: student)

    if student_items.count == 1 && student_items.first.product_type == 'Membership'
      membership_items.destroy_all
    end
    # Supprimer les membreships qui ne sont plus nécessaires
    remaining_years = student_items.map do |item|
      case item.product_type
      when 'CampEnrollment'
        camp = item.product.camp
        start_year = camp.starts_at.month >= 9 ? camp.starts_at.year : camp.starts_at.year - 1
        start_year
      when 'AnnualProgramEnrollment'
        item.product.annual_program.starts_at.year
      end
    end

    membership_items.each do |membership_item|
      membership = membership_item.product
      membership_year = membership.start_year
      unless remaining_years.include?(membership_year)
        membership_item.destroy
      end
    end
  end

  def cart_item_params
    params.require(:commerce_cart_item).permit(:product, :price, :payment_method, :student_id)
  end
end
