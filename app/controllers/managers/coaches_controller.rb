class Managers::CoachesController < ApplicationController

  def index
    academy_ids = current_user.academies_as_manager.pluck(:id)
    @coaches =  User.joins(:coach_academies).where(coach_academies: { academy_id: academy_ids })
                    .joins(:roles).where(roles: { name: "coach" }).uniq
  end

  def show
    @coach = User.find(params[:id])
  end

  def new
    @coach = User.new
    @academies = Academy.all
    @categories = Category.all
  end

  def create
    @coach = User.new(coach_params)
    @coach.password = Devise.friendly_token[0, 8]
    if @coach.save
      @coach.roles << Role.find_by(name: "coach")
      @coach.academies_as_coach << Academy.find(params[:user][:academy_1_id])
      @coach.academies_as_coach << Academy.find(params[:user][:academy_2_id]) if params[:user][:academy_2_id].present?
      @coach.categories << Category.find(params[:user][:category_1_id])
      @coach.categories << Category.find(params[:user][:category_2_id]) if params[:user][:category_2_id].present?
      flash[:notice] = "Coach ajouté avec succès."
      redirect_to managers_coaches_path
    else
      @academies = Academy.all
      @categories = Category.all
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @coach = User.find(params[:id])
    @academies = Academy.all
    @categories = Category.all
    @academy1 = @coach.academies_as_coach.first ? @coach.academies_as_coach.first.id : ""
    @academy2 = @coach.academies_as_coach.second ? @coach.academies_as_coach.second.id : ""
    @category1 = @coach.categories.first ? @coach.categories.first.id : ""
    @category2 = @coach.categories.second ? @coach.categories.second.id : ""
  end



  def update
    @coach = User.find(params[:id])
    @coach.academies_as_coach.clear
    @coach.academies_as_coach << Academy.find(params[:user][:academy_1_id])
    @coach.academies_as_coach << Academy.find(params[:user][:academy_2_id]) if params[:user][:academy_2_id].present?
    @coach.categories.clear
    @coach.categories << Category.find(params[:user][:category_1_id])
    @coach.categories << Category.find(params[:user][:category_2_id]) if params[:user][:category_2_id].present?
    flash[:notice] = "Coach mis à jour."
    redirect_to managers_coaches_path
  end

  private

  def coach_params
    params.require(:user).permit(:email, :first_name, :last_name, :password)
  end
end
