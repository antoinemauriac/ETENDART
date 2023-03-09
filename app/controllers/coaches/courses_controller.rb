class Coaches::CoursesController < ApplicationController

  before_action :course, only: %i[show]

  def index
    @coach = current_user
    @current_time = Time.current
    @camps = current_user.camps.where('ends_at >= ?', @current_time - 2.hour)
    skip_policy_scope
    authorize([:coaches, @camps], policy_class: Coaches::CoursePolicy)
  end

  def show
    @enrollments = course.course_enrollments.joins(:student).order(last_name: :asc)
    authorize([:coaches, @course], policy_class: Coaches::CoursePolicy)
  end

  def update_enrollments
    enrollments_params = params[:enrollments]
    authorize([:coaches, @enrollments], policy_class: Coaches::CoursePolicy)
    enrollments_params.each do |enrollment_params|
      enrollment = CourseEnrollment.find(enrollment_params[0].to_i)
      enrollment.update(present: enrollment_params[1][:present].to_i)
    end
    redirect_to coaches_course_path(params[:id])
    flash[:notice] = "Appel mis à jour"
  end

  private

  def course
    @course ||= Course.find(params[:id])
  end
end
