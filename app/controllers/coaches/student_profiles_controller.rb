class Coaches::StudentProfilesController < ApplicationController
  def show
    @student = Student.find(params[:id])
    authorize([:coaches, @student], policy_class: Coaches::StudentProfilePolicy)
    @feedbacks = @student.feedbacks.where(coach_id: current_user.id).order(created_at: :desc)
    @feedback = Feedback.new
    @course = Course.find(params[:course_id]) if params[:course_id]
    @camp_enrollment = CampEnrollment.find_by(student: @student, camp: @course&.camp) if @course&.camp&.school_period&.paid
    @annual_program_enrollment = AnnualProgramEnrollment.find_by(student: @student, annual_program: @course&.annual_program) if @course&.annual_program&.paid
    @origin = params[:origin]
  end

  def index
    @students = current_user.students.includes(:photo_attachment).distinct.order(:last_name)
    skip_policy_scope
    authorize([:coaches, @students], policy_class: Coaches::StudentProfilePolicy)
  end
end
