class Commerce::CheckoutController < ApplicationController

  def new
    authorize [:commerce, :checkout], :new?
    @parent = current_user
    @parent_profile = @parent.parent_profile
    @cart = @parent.pending_cart
    @cart_items = @cart.cart_items.where(payment_method: 'carte bancaire')
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
    @cart.cart_items.where(payment_method: 'virement').each(&:paid!)

    flash[:notice] = 'Votre paiement a bien été effectué.'
  end

  def cancel
    authorize [:commerce, :checkout], :cancel?
    flash[:alert] = 'Votre paiement a été annulé.'
  end
end
