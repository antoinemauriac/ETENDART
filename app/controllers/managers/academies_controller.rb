class Managers::AcademiesController < ApplicationController

  def index
    @academies = current_user.academies_as_manager
    skip_policy_scope
    authorize [:managers, @academies]
  end


  def show
    @academy = Academy.find(params[:id])
    authorize [:managers, @academy]
    @coaches = @academy.coaches

    @locations = @academy.locations
    @location = Location.new

    @students = @academy.students
    @camps = @academy.camps.where(starts_at: Date.today..Date.today + 1.year)
    @school_period = SchoolPeriod.new
  end

  private

  def academy_params
    params.require(:academy).permit(:name)
  end
end
