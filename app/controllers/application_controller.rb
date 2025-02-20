class ApplicationController < ActionController::Base
  before_action :authenticate_user!
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
    if resource.first_login
      users_first_login_path # Redirige vers une page spéciale pour les utilisateurs qui se connectent pour la première fois
    elsif !resource.first_login && resource.parent_profile.nil?
      new_parents_profile_path # Redirige vers la création du profil parent
    else
      super # Utilise le chemin par défaut fourni par Devise ou celui que tu as configuré
    end
  end

  private

  def skip_pundit?
    devise_controller? || params[:controller] =~ /(^(rails_)?admin)|(^pages$)/
  end
end
