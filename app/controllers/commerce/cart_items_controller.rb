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
    student = cart_item.student
    camp_enrollment = cart_item.product if cart_item.product_type == 'CampEnrollment'
    camp = camp_enrollment.camp if camp_enrollment
    school_period_enrollment = student.school_period_enrollments.find_by(school_period: camp.school_period) if camp
    school_period = school_period_enrollment.school_period if school_period_enrollment
    cart_item.destroy
    if camp_enrollment
      # activities_enrollments = camp_enrollment.student.activity_enrollments.where(activity: camp_enrollment.camp.activities)
      camp_enrollment.destroy
      student.activity_enrollments.where(activity: camp.activities).destroy_all
      camp_enrollments = student.camp_enrollments.where(camp: school_period.camps)
      if camp_enrollments.empty?
        school_period_enrollment.destroy
        cart = cart_item.cart
        student_items = cart.cart_items.where(student: student)
        membership_item = cart.cart_items.find_by(product_type: 'Membership', student: student)
        if student_items == [membership_item]
          membership_item.destroy
        end
      end
    end

    redirect_to commerce_cart_path, notice: "L'inscription au stage a été annulée"
  end

  private

  def cart_item_params
    params.require(:commerce_cart_item).permit(:product, :price, :payment_method, :student_id)
  end
end
