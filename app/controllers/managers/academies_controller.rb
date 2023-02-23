class Managers::AcademiesController < ApplicationController
  def index
    @academies = current_user.academies_as_manager
  end

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
