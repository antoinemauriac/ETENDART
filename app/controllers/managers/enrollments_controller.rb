class Managers::EnrollmentsController < ApplicationController

  # def new
  #   @student = Student.find(params[:id])
  #   @academy = @student.academies.first
  # end

  def create
    @student = Student.find(params[:student_id])

    # school_period = SchoolPeriod.find(params[:school_period])
    # @student.school_periods << school_period

    camp = Camp.find(params[:camp])
    @student.camps << camp

    activity = Activity.find(params[:activity])
    @student.activities << activity

    redirect_to managers_student_path(@student)
  end
end
