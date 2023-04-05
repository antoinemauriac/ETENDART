# frozen_string_literal: true

class Users::PasswordsController < Devise::PasswordsController
  # GET /resource/password/new
  # def new
  #   super
  # end

  # POST /resource/password
  # def create
  #   super
  # end

  # GET /resource/password/edit?reset_password_token=abcdef
  # def edit
  #   super
  # end

  # PUT /resource/password
  def update
    super do |resource|
      # Si la réinitialisation de mot de passe a réussi et que l'utilisateur a coché la case "se souvenir de moi"
      if resource.errors.empty? && resource.remember_me == "1"
        # Crée une nouvelle session pour l'utilisateur
        sign_in(resource_name, resource)
      end
    end
  end

  # protected

  # protected

  # def after_resetting_password_path_for(resource)
  #   root_path
  # end

  # The path used after sending reset password instructions
  # def after_sending_reset_password_instructions_path_for(resource_name)
  #   super(resource_name)
  # end
end
