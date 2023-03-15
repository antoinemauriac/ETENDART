class Managers::CoachesController < ApplicationController
  # skip_before_action :authenticate_user!, only: [:change_password]

  def index
    @academy = Academy.find(params[:academy_id])
    @coaches = @academy.coach_academies.includes(:coach).map(&:coach)
    skip_policy_scope
    authorize([:managers, @coaches], policy_class: Managers::CoachPolicy)
  end

  def show
    @coach = User.find(params[:id])
    authorize([:managers, @coach], policy_class: Managers::CoachPolicy)
    @academies = Academy.all
    @categories = Category.all
    academies_ordered = @coach.academies_ordered
    @academy1 = academies_ordered.first ? academies_ordered.first.id : ""
    @academy2 = academies_ordered.second ? academies_ordered.second.id : ""
    @category1 = @coach.categories.first ? @coach.categories.first.id : ""
    @category2 = @coach.categories.second ? @coach.categories.second.id : ""
    @academy = Academy.find(params[:academy_id])
  end

  def new
    @coach = User.new
    authorize([:managers, @coach], policy_class: Managers::CoachPolicy)
    @academies = Academy.all
    @categories = Category.all
    @academy = Academy.find(params[:academy_id])
  end

  def create
    @coach = User.new(coach_params)
    @academy = Academy.find(params[:user][:academy_1_id])
    authorize([:managers, @coach], policy_class: Managers::CoachPolicy)
    @coach.password = Devise.friendly_token[0, 8]
    if @coach.save
      @coach.roles << Role.find_by(name: "coach")
      @coach.academies_as_coach << Academy.find(params[:user][:academy_1_id])
      @coach.academies_as_coach << Academy.find(params[:user][:academy_2_id]) if params[:user][:academy_2_id].present?
      @coach.categories << Category.find(params[:user][:category_1_id])
      @coach.categories << Category.find(params[:user][:category_2_id]) if params[:user][:category_2_id].present?

      @coach.update(status: "creation")
      # Envoie l'e-mail avec le lien de réinitialisation de mot de passe
      @coach.send_reset_password_instructions

      @coach.update(status: "")

      flash[:notice] = "Coach ajouté avec succès."
      redirect_to managers_coach_path(@coach, academy_id: @academy.id)
    else
      @academies = Academy.all
      @categories = Category.all
      render :new, status: :unprocessable_entity
      flash[:alert] = "Une erreur est survenue"
    end
  end

  # def edit
  #   @coach = User.find(params[:id])
  #   authorize([:managers, @coach], policy_class: Managers::CoachPolicy)
  #   @academies = Academy.all
  #   @categories = Category.all
  #   @academy1 = @coach.academies_as_coach.first ? @coach.academies_as_coach.first.id : ""
  #   @academy2 = @coach.academies_as_coach.second ? @coach.academies_as_coach.second.id : ""
  #   @category1 = @coach.categories.first ? @coach.categories.first.id : ""
  #   @category2 = @coach.categories.second ? @coach.categories.second.id : ""
  # end

  def update
    @coach = User.find(params[:id])
    authorize([:managers, @coach], policy_class: Managers::CoachPolicy)
    @coach.academies_as_coach.clear
    @coach.academies_as_coach << Academy.find(params[:user][:academy_1_id])
    @coach.academies_as_coach << Academy.find(params[:user][:academy_2_id]) if params[:user][:academy_2_id].present?
    @coach.categories.clear
    @coach.categories << Category.find(params[:user][:category_1_id])
    @coach.categories << Category.find(params[:user][:category_2_id]) if params[:user][:category_2_id].present?
    flash[:notice] = "Coach mis à jour."
    redirect_to managers_coach_path(@coach)
  end

  # def change_password
  #   @coach = User.find_by(confirmation_token: params[:token])

  #   if @coach
  #     # rediriger vers la vue change_password.html.erb dans views/managers/coaches/
  #     render "managers/coaches/change_password"
  #   else
  #     # coach non trouvé, rediriger vers la page d'accueil
  #     redirect_to "/"
  #     flash[:alert] = "Une erreur est survenue"
  #   end
  # end

  def category_coaches
    category = Category.find(params[:category_id])
    authorize([:managers, category])
    academy = Academy.find(params[:academy_id])
    coaches = category.coaches.joins(:coach_academies).where(coach_academies: { academy_id: academy.id })
    render json: coaches.select(:id, :first_name, :last_name, :email)
  end

  private

  def coach_params
    params.require(:user).permit(:email, :first_name, :last_name, :password, :phone_number)
  end
end
