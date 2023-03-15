class Coaches::CoursesController < ApplicationController

  before_action :course, only: %i[show]

  def index
    @coach = current_user
    @current_time = Time.current
    @next_courses = @coach.next_courses
    @past_courses = @coach.past_courses
    skip_policy_scope
    authorize([:coaches, @camps], policy_class: Coaches::CoursePolicy)
  end

  def show
    @enrollments = course.course_enrollments.joins(:student).order(last_name: :asc)
    authorize([:coaches, @course], policy_class: Coaches::CoursePolicy)
  end

  def update_enrollments
    course = Course.find(params[:id])
    enrollments_params = params[:enrollments]
    authorize([:coaches, @enrollments], policy_class: Coaches::CoursePolicy)
    if enrollments_params.present?
      enrollments_params.each do |enrollment_params|
        enrollment = CourseEnrollment.find(enrollment_params[0].to_i)
        enrollment.update(present: enrollment_params[1][:present].to_i)
      end
      course.update(status: true)
      redirect_to coaches_course_path(course)
      flash[:notice] = "Feuille d'appel validée."
    else
      redirect_to coaches_course_path(course)
      flash[:alert] = "Aucun élève dans ce cours"
    end
  end

  private

  def course
    @course ||= Course.find(params[:id])
  end
end
