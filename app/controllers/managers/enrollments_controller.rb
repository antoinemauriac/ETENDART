class Managers::EnrollmentsController < ApplicationController

  def new
    @student = Student.find(params[:id])
    @academy = @student.academies.first
    @enrollment = Enrollment.new
  end

  def create
    @student = Student.find(params[:enrollment][:student_id])

    camp = Camp.find(params[:enrollment][:camp])
    @student.camps << camp

    # camp = Camp.find(params[:camp_id])
    # @student.camps << camp

    redirect_to managers_student_path(@student)
  end
end
