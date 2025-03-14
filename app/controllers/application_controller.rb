class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :ensure_parent_profile
  include Pundit::Authorization
  include Pagy::Backend

  # Pundit: allow-list approach
  after_action :verify_authorized, except: :index, unless: :skip_pundit?
  after_action :verify_policy_scoped, only: :index, unless: :skip_pundit?

  # Uncomment when you *really understand* Pundit!
  # rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  # def user_not_authorized
  #   flash[:alert] = "Vous n'êtes pas autorisé à accéder à cette page/action"
  #   redirect_to(root_path)
  # end

  protected

  def after_sign_in_path_for(resource)
    if resource.first_login || (resource.parent_profile.nil? && resource.parent?)
      resource.first_login = false
      resource.roles << Role.find_by(name: "parent") if resource.roles.empty?
      resource.save
      new_parents_profile_path # Redirige vers une page spéciale pour les utilisateurs qui se connectent pour la première fois
    else
      super # Utilise le chemin par défaut fourni par Devise ou celui que tu as configuré
    end
  end

  private

  def skip_pundit?
    devise_controller? || params[:controller] =~ /(^(rails_)?admin)|(^pages$)/
  end

  def ensure_parent_profile
    return unless user_signed_in?
    return unless current_user.parent?
    return if current_user.parent_profile.present?
    allowed_paths = [
      new_parents_profile_path,    # Formulaire de création du profil
      destroy_user_session_path   # Permettre la déconnexion
    ]

    unless allowed_paths.include?(request.path)
      flash[:alert] = "Vous devez compléter votre profil pour continuer."
      redirect_to new_parents_profile_path
    end
  end
end
