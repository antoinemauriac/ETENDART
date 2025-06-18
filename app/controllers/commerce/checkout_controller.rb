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
      success_url: commerce_checkout_success_url + "?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: commerce_checkout_cancel_url,
      line_items: @cart_items.map { |item| { price: item.stripe_price_id, quantity: 1 } },
      metadata: { cart_id: @cart.id }
    )

    @cart.update!(stripe_payment_intent_id: session.payment_intent)
    redirect_to session.url, allow_other_host: true
  end

  def success
    authorize [:commerce, :checkout], :success?
    @parent = current_user

    begin
      @cart = find_cart_from_params_or_stripe!
    rescue => e
      Rails.logger.warn "[Checkout] Échec : #{e.message}"
      return redirect_to root_path, alert: e.message
    end

    return redirect_to root_path, alert: 'Ce panier ne vous appartient pas.' unless @cart&.parent == @parent
    return redirect_to root_path, notice: 'Le panier a déjà été payé.' if @cart.paid?

    finalize_cart!(@cart)

    @academy = @cart.cart_items.find_by(product_type: 'CampEnrollment')&.product&.camp&.academy
    @camp_enrollment_cart_items = @cart.cart_items.where(product_type: 'CampEnrollment')
    @membership_cart_items = @cart.cart_items.where(product_type: 'Membership')
    @enrollments = Commerce::CartItem.group_by_student(@camp_enrollment_cart_items)

    CheckoutMailer.payment_summary(@parent, @enrollments, @membership_cart_items, @academy).deliver_now

    Commerce::Cart.create!(parent: @parent, status: 'pending', total_price: 0) unless @parent.pending_cart
  end

  def cancel
    authorize [:commerce, :checkout], :cancel?
    flash[:notice] = 'Votre paiement a été annulé.'
  end

  private

  def find_cart_from_params_or_stripe!
    if params[:session_id].present?
      stripe_session = Stripe::Checkout::Session.retrieve(params[:session_id])
      raise "Paiement non confirmé" unless stripe_session.payment_status == "paid"

      Commerce::Cart.find(stripe_session.metadata.cart_id)
    elsif params[:cart_id].present?
      cart = Commerce::Cart.find(params[:cart_id])
      if cart.cart_items.where(payment_method: 'Carte bancaire').exists?
        raise "Le panier contient des articles à payer en CB."
      end
      cart
    else
      raise "Panier introuvable"
    end
  end

  def finalize_cart!(cart)
    cart.paid!
    cart.cart_items.where(payment_method: 'Carte bancaire').each do |item|
      item.paid!
      item.product.update!(payment_method: 'virement') if item.product_type == 'CampEnrollment'
    end

    cart.cart_items.where(product_type: 'CampEnrollment').each do |item|
      item.product.update!(confirmed: true)
      item.product.update!(paid: true, payment_date: Date.current, payment_method: 'offert') if item.product.camp.price == 0
      confirm_activity_enrollments_for(item.product)
    end
  end

  def confirm_activity_enrollments_for(camp_enrollment)
    student = camp_enrollment.student
    camp_enrollment.camp.activities.each do |activity|
      activity_enrollment = student.activity_enrollments.find_by(activity: activity)
      next unless activity_enrollment
      activity_enrollment.update!(confirmed: true)
      student.courses << activity.next_courses
    end
  end
end
