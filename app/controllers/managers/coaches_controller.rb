class Managers::CoachesController < ApplicationController

  def index
    @academy = Academy.find(params[:academy])
    if params[:query].present?
      @coaches = @academy.coaches.search_by_query(params[:query]).order(:last_name)
    else
      @coaches = @academy.coaches.order(:last_name)
    end
    skip_policy_scope
    authorize([:managers, @coaches], policy_class: Managers::CoachPolicy)
    @pagy, @coaches = pagy(@coaches, items: 100)
    respond_to do |format|
      format.html
      format.text { render partial: "managers/coaches/list", locals: {coaches: @coaches}, formats: [:html] }
    end
  end

  def show
    @coach = User.find(params[:id])
    authorize([:managers, @coach], policy_class: Managers::CoachPolicy)
    @academies = current_user.academies_as_manager
    @coach_feedback = CoachFeedback.new
    @coach_feedbacks = @coach.coach_feedbacks.order(created_at: :desc)
    @categories = Category.order(:name)
    academies_ordered = @coach.academies_ordered
    @academy1 = academies_ordered.first ? academies_ordered.first.id : ""
    @academy2 = academies_ordered.second ? academies_ordered.second.id : ""
    @academy3 = academies_ordered.third ? academies_ordered.third.id : ""
    @category1 = @coach.categories.first ? @coach.categories.first.id : ""
    @category2 = @coach.categories.second ? @coach.categories.second.id : ""
    @category3 = @coach.categories.third ? @coach.categories.third.id : ""
    @category4 = @coach.categories.fourth ? @coach.categories.fourth.id : ""
    @category5 = @coach.categories.fifth ? @coach.categories.fifth.id : ""
    @academy = Academy.find(params[:academy_id])
  end

  def new
    @coach = User.new
    authorize([:managers, @coach], policy_class: Managers::CoachPolicy)
    @academies = current_user.academies_as_manager
    @categories = Category.all
    @academy = Academy.find(params[:academy_id])
  end

  def create
    coach = User.new(coach_params)
    academy = Academy.find(params[:user][:academy_1_id])
    authorize([:managers, coach], policy_class: Managers::CoachPolicy)
    coach.password = Devise.friendly_token[0, 8]
    if coach.save
      coach.roles << Role.find_by(name: "coach")
      update_academies(coach, params)
      update_categories(coach, params)
      coach.update(status: "creation")
      # Envoie l'e-mail avec le lien de réinitialisation de mot de passe
      coach.send_reset_password_instructions

      coach.update(status: "")

      flash[:notice] = "Coach ajouté avec succès."
      redirect_to managers_coaches_path(academy: academy)
    else
      @academies = Academy.all
      @categories = Category.all
      render :new, status: :unprocessable_entity
      flash[:alert] = "Une erreur est survenue"
    end
  end

  def update
    coach = User.find(params[:id])
    authorize([:managers, coach], policy_class: Managers::CoachPolicy)
    coach.academies_as_coach.clear
    update_academies(coach, params)
    coach.categories.clear
    update_categories(coach, params)

    flash[:notice] = "Coach mis à jour."
    redirect_to managers_coach_path(coach)
  end

  def update_infos
    @coach = User.find(params[:id])
    authorize([:managers, @coach], policy_class: Managers::CoachPolicy)
    @coach.update(coach_params)
    flash[:notice] = "Coach mis à jour."
    redirect_to managers_coach_path(@coach)
  end

  def category_coaches
    category = Category.find(params[:category_id])
    authorize([:managers, category])
    academy = Academy.find(params[:academy_id])
    coaches = category.coaches.joins(:coach_academies).where(coach_academies: { academy_id: academy.id }).order(:first_name)
    render json: coaches.select(:id, :first_name, :last_name, :email)
  end

  private

  def update_academies(coach, params)
    first_academy = Academy.find(params[:user][:academy_1_id]) if params[:user][:academy_1_id].present?
    second_academy = Academy.find(params[:user][:academy_2_id]) if params[:user][:academy_2_id].present?
    third_academy = Academy.find(params[:user][:academy_3_id]) if params[:user][:academy_3_id].present?

    coach.academies_as_coach << first_academy unless coach.academies_as_coach.include?(first_academy) || first_academy.nil?
    coach.academies_as_coach << second_academy unless coach.academies_as_coach.include?(second_academy) || second_academy.nil?
    coach.academies_as_coach << third_academy unless coach.academies_as_coach.include?(third_academy) || third_academy.nil?
  end

  def update_categories(coach, params)
    first_category = Category.find(params[:user][:category_1_id]) if params[:user][:category_1_id].present?
    second_category = Category.find(params[:user][:category_2_id]) if params[:user][:category_2_id].present?
    third_category = Category.find(params[:user][:category_3_id]) if params[:user][:category_3_id].present?
    fourth_category = Category.find(params[:user][:category_4_id]) if params[:user][:category_4_id].present?
    fifth_category = Category.find(params[:user][:category_5_id]) if params[:user][:category_5_id].present?

    coach.categories << first_category unless coach.categories.include?(first_category) || first_category.nil?
    coach.categories << second_category unless coach.categories.include?(second_category) || second_category.nil?
    coach.categories << third_category unless coach.categories.include?(third_category) || third_category.nil?
    coach.categories << fourth_category unless coach.categories.include?(fourth_category) || fourth_category.nil?
    coach.categories << fifth_category unless coach.categories.include?(fifth_category) || fifth_category.nil?
  end


  def coach_params
    params.require(:user).permit(:email, :first_name, :last_name, :password, :phone_number, :gender)
  end
end
