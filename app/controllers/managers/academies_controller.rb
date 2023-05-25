class Managers::AcademiesController < ApplicationController

  def index
    @academies = current_user.academies_as_manager
    skip_policy_scope
    authorize [:managers, @academies]
  end


  def show
    @academy = Academy.find(params[:id])
    authorize [:managers, @academy]

    @feedbacks = Feedback.last_five(@academy)
    @today_courses = @academy.today_courses
    @tomorrow_courses = @academy.tomorrow_courses
    @today_absent_students = @academy.today_absent_students
    @camp = @academy.camps.where("starts_at <= ? AND ends_at >= ?", Time.current, Time.current).first
    if @camp.present?
      @banished_students = @camp.banished_students
    else
      @banished_students = []
    end
    @course = Course.first



    # @coaches = @academy.coaches

    # @locations = @academy.locations
    # @location = Location.new

    # @students = @academy.students
    # @camps = @academy.camps.where(starts_at: Date.today..Date.today + 1.year)
    # @school_period = SchoolPeriod.new
  end

  private

  def academy_params
    params.require(:academy).permit(:name)
  end

end
