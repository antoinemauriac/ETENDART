class Coaches::StudentProfilesController < ApplicationController

  def show
    @student = Student.find(params[:id])
    # @start_year = Date.current.month >= 9 ? Date.current.year : Date.current.year - 1
    # @membership = @student.memberships.find_by(start_year: @start_year)
    authorize([:coaches, @student], policy_class: Coaches::StudentProfilePolicy)
    @feedbacks = @student.feedbacks.where(coach_id: current_user.id).order(created_at: :desc)
    @feedback = Feedback.new
    @course = Course.find(params[:course_id]) if params[:course_id]
    if @course && @course.camp && @course.camp.school_period.paid
      @camp_enrollment = CampEnrollment.find_by(student: @student, camp: @course.camp)
    end
    @origin = params[:origin]
  end

  def index
    @students = current_user.students.includes(:photo_attachment).distinct.order(:last_name)
    skip_policy_scope
    authorize([:coaches, @students], policy_class: Coaches::StudentProfilePolicy)
  end
end
