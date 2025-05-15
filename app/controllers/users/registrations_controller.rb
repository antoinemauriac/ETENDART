# frozen_string_literal: true

require 'net/http'
require 'uri'
require 'json'

class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]
  # before_action :configure_account_update_params, only: [:update]

  # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  def create
    recaptcha_token = params[:recaptcha_token]
    recaptcha_response = verify_recaptcha_v3(recaptcha_token)

    if recaptcha_response && recaptcha_response['success'] && recaptcha_response['score'] > 0.2
      super
      if resource.persisted?
        resource.roles << Role.find_by(name: "parent") if resource.roles.empty?
        Commerce::Cart.create!(parent: resource, status: 'pending', total_price: 0)
        resource.save
      end
    else
      flash[:alert] = "Échec de la vérification reCAPTCHA. Veuillez réessayer."
      clean_up_passwords(resource)
      set_minimum_password_length
      redirect_to new_user_registration_path and return
    end
  rescue ArgumentError => e
    Rails.logger.error("Registration error: \\#{e.message}")
    flash[:alert] = "Une erreur inattendue s'est produite. Veuillez réessayer."
    redirect_to new_user_registration_path
  end

  def confirmation_pending
    # Cette action peut rester vide si vous n'avez pas besoin de logique spécifique
  end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:email, :password, :first_name, :last_name, :phone_number])
  end

  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:email, :password, :password_confirmation, :current_password, :first_name, :last_name, :phone_number, parent_profile_attributes: [:id, :gender, :relationship_to_child, :address, :city, :zipcode, :has_newsletter]])
  end

  def after_inactive_sign_up_path_for(resource)
    confirmation_pending_path
  end

  # If you have extra params to permit, append them to the sanitizer.
  # def configure_account_update_params
  #   devise_parameter_sanitizer.permit(:account_update, keys: [:attribute])
  # end

  # The path used after sign up.
  # def after_sign_up_path_for(resource)
  #   super(resource)
  # end

  # The path used after sign up for inactive accounts.
  # def after_inactive_sign_up_path_for(resource)
  #   super(resource)
  # end

  private

  def verify_recaptcha_v3(token)
    secret_key = ENV['RECAPTCHA_SECRET_KEY']
    uri = URI.parse("https://www.google.com/recaptcha/api/siteverify")
    response = Net::HTTP.post_form(uri, { 'secret' => secret_key, 'response' => token })
    JSON.parse(response.body)
  end
end
