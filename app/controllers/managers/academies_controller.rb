class Managers::AcademiesController < ApplicationController
  def index
    @academies = current_user.academies
  end

  # def new
  #   @academy = Academy.new
  # end

  # def create
  #   @academy = Academy.new(academy_params)
  #   @academy.manager = current_user
  #   if @academy.save
  #     redirect_to managers_academy_path(@academy)
  #     flash[:notice] = "Academie créée"
  #   else
  #     render :new, status: :unprocessable_entity
  #   end
  # end

  def show
    @academy = Academy.find(params[:id])
    @coaches = @academy.coaches

    @locations = @academy.locations
    @location = Location.new

    @students = @academy.students
    @camps = @academy.camps.where(starts_at: Date.today..Date.today + 1.year)
    @school_period = SchoolPeriod.new
  end

  # def edit
  #   @academy = Academy.find(params[:id])
  # end

  # def update
  #   @academy = Academy.find(params[:id])
  #   if @academy.update(academy_params)
  #     redirect_to managers_academy_path(@academy)
  #     flash[:notice] = "Academie mise à jour"
  #   else
  #     render :edit, status: :unprocessable_entity
  #   end
  # end

  private

  def academy_params
    params.require(:academy).permit(:name)
  end
end
