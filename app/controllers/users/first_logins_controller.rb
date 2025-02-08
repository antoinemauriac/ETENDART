class Users::FirstLoginsController < ApplicationController
  def show
    @user = current_user
    authorize [:users, :first_login], :show?
  end

  def update
    @user = current_user
    authorize [:users, :first_login], :update?
    @user.first_login = false
    @role = Role.find_by(name: 'parent')
    @user.roles << @role
    if @user.save
      redirect_to new_parents_profile_path, notice: 'Bienvenu chez Etendart ! Veuillez compléter votre profil.'
    else
      render :show, alert: 'Une erreur est survenue. Veuillez réessayer.'
    end
  end
end
