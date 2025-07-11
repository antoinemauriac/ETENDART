class Commerce::CartsController < ApplicationController
  def show
    @parent = current_user
    @cart = @parent.pending_cart
    authorize @cart
    if session[:cart_warning]
      session[:cart_warning] = false
      session.delete(:cart_warning)
    end
    @membership_cart_items = @cart.cart_items.where(product_type: 'Membership')
    @camp_enrollment_cart_items = @cart.cart_items.where(product_type: 'CampEnrollment').order(:created_at)
    @annual_program_enrollment_cart_items = @cart.cart_items.where(product_type: 'AnnualProgramEnrollment').order(:created_at)
    @total_cb = @cart.cart_items.where(payment_method: 'Carte bancaire').sum(:price)
    @total_other = @cart.cart_items.where.not(payment_method: 'Carte bancaire').sum(:price)
  end
end
