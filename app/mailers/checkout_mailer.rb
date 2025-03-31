class CheckoutMailer < ApplicationMailer
  def payment_summary(parent, enrollments, membership_cart_items, academy)
    @parent = parent
    @enrollments = enrollments
    @membership_cart_items = membership_cart_items
    @academy = academy
    mail(to: @parent.email, subject: 'Récapitulatif de votre paiement')
  end
end