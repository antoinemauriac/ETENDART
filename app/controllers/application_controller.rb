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
    elsif resource.parent? && resource.parent_profile
      render_cart_warning_for(resource)
      parents_children_path # Redirige vers la page d'accueil des parents
    else
      super # Utilise le chemin par défaut fourni par Devise ou celui que tu as configuré
    end
  end

  private

  def skip_pundit?
    devise_controller? || params[:controller] =~ /(^(rails_)?admin)|(^pages$)/
  end

  def ensure_parent_profile
    # si l'utilisateur n'est pas connecté, ou n'est pas un parent ou a déjà complété son profil, on ne fait rien
    return unless user_signed_in?
    return if !current_user.parent? || current_user.parent_profile.present?
    # seul les parents doivent compléter leur profil
    allowed_paths = [
      new_parents_profile_path,    # Formulaire de création du profil
      destroy_user_session_path,   # Permettre la déconnexion
      parents_profile_path      # Permettre la création du profil
    ]
    unless allowed_paths.include?(request.path)
      flash[:alert] = "Vous devez compléter votre profil pour pouvoir continuer."
      redirect_to new_parents_profile_path
    end
  end
  
  def render_cart_warning_for(resource)
    if resource.has_items_to_valid?
      session[:cart_warning] = true
    end
  end
end
