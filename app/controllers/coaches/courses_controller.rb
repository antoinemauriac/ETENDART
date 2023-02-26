class Coaches::CoursesController < ApplicationController

  before_action :course, only: %i[show]

  def index
    @coach = current_user
    @current_time = Time.now.in_time_zone('Paris')
    @camps = current_user.camps.where('ends_at >= ?', @current_time - 2.hour)
  end

  def show
    @enrollments = course.course_enrollments.joins(:student).order(last_name: :asc)
  end

  def update_enrollments
    enrollments_params = params[:enrollments]
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
