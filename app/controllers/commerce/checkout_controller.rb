class Commerce::CheckoutController < ApplicationController

  def new
    authorize [:commerce, :checkout], :new?
    @parent = current_user
    @parent_profile = @parent.parent_profile
    @cart = @parent.pending_cart
    @cart_items = @cart.cart_items.where(payment_method: 'Carte bancaire')
    session = Stripe::Checkout::Session.create(
      customer: @parent_profile.stripe_customer_id,
      payment_method_types: ['card'],
      mode: 'payment',
      billing_address_collection: 'required',
      success_url: commerce_checkout_success_url,
      cancel_url: commerce_checkout_cancel_url,
      line_items: @cart_items.map do |cart_item|
        {
          price: cart_item.stripe_price_id,
          quantity: 1
        }
      end
    )
    @cart.update!(stripe_payment_intent_id: session.payment_intent)
    redirect_to session.url, allow_other_host: true
  end

  def success
    authorize [:commerce, :checkout], :success?
    @parent = current_user
    @cart = @parent.pending_cart
    @cart.paid! unless @cart.paid?
    # chaque cart_items dont la payment_method est 'Carte bancaire' est marqué comme payé
    paid_cart_items = @cart.cart_items.where(payment_method: 'Carte bancaire')
    paid_cart_items.each do |item|
      item.paid!
      # chaque product_type camp_enrollment de ces cart_items obtient une payment_method = "virement"
      item.product.update!(payment_method: 'virement') if item.product_type == 'CampEnrollment'
    end

    # chaque camp_enrollment de ces cart_items passe confirmed à true
    @camp_enrollment_cart_items = @cart.cart_items.where(product_type: 'CampEnrollment')
    @camp_enrollment_cart_items.each do |item|
      item.product.update!(confirmed: true)
      activity_enrollments = item.product.student.activity_enrollments.where(activity: item.product.camp.activities)
      activity_enrollments.each do |activity_enrollment|
        activity_enrollment.update!(confirmed: true)
        student = activity_enrollment.student
        activity = activity_enrollment.activity
        student.courses << activity.next_courses
      end
    end

    @academy = @camp_enrollment_cart_items.first.product.camp.academy

    @enrollments = Commerce::CartItem.group_by_student(@camp_enrollment_cart_items)
    @membership_cart_items = @cart.cart_items.where(product_type: 'Membership')
    CheckoutMailer.payment_summary(@parent, @enrollments, @membership_cart_items, @academy).deliver_now

    Cart.create!(parent: @parent, status: 'pending', total_price: 0)

    flash[:notice] = 'Votre inscription a bien été effectuée.'
  end

  def cancel
    authorize [:commerce, :checkout], :cancel?
    flash[:alert] = 'Votre paiement a été annulé.'
  end
end
