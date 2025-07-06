class CheckoutMailer < ApplicationMailer
  def payment_summary(parent, enrollments, annual_enrollments, membership_cart_items, academy)
    @parent = parent
    @enrollments = enrollments
    @annual_enrollments = annual_enrollments
    @membership_cart_items = membership_cart_items
    @academy = academy
    mail(to: @parent.email, subject: 'Récapitulatif de votre paiement')
  end
end
