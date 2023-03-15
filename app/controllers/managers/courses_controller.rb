class Managers::CoursesController < ApplicationController
  before_action :course, only: %i[edit show update destroy]

  def index
    @courses = current_user.courses_as_manager.sort_by(&:starts_at)
    skip_policy_scope
    authorize([:managers, @courses], policy_class: Managers::CoursePolicy)
  end

  def show
    @enrollments = course.course_enrollments.joins(:student).order(last_name: :asc)
    @academy = course.activity.academy
    authorize([:managers, @course], policy_class: Managers::CoursePolicy)
  end

  def edit
    authorize([:managers, @course], policy_class: Managers::CoursePolicy)
  end

  def update
    authorize([:managers, @course], policy_class: Managers::CoursePolicy)
    if course.update(course_params)
      redirect_to managers_activity_path(course.activity)
      flash[:notice] = "Cours mis à jour"
    else
      flash[:alert] = "L'heure de début doit être avant l'heure de fin"
      redirect_to managers_activity_path(course.activity)
    end
  end

  def destroy
    authorize([:managers, @course], policy_class: Managers::CoursePolicy)
    course.destroy
    redirect_to managers_activity_path(course.activity)
    flash[:notice] = "Cours supprimé"
  end

  def update_enrollments
    course = Course.find(params[:id])
    enrollments_params = params[:enrollments]
    authorize([:managers, @enrollments], policy_class: Managers::CoursePolicy)
    if enrollments_params.present?
      enrollments_params.each do |enrollment_params|
        enrollment = CourseEnrollment.find(enrollment_params[0].to_i)
        enrollment.update(present: enrollment_params[1][:present].to_i)
      end
      course.update(status: true)
      redirect_to managers_course_path(course)
      flash[:notice] = "Appel mis à jour"
    else
      redirect_to managers_course_path(course)
      flash[:alert] = "Aucun élève dans ce cours"
    end
  end

  private

  def course
    @course ||= Course.find(params[:id])
  end

  def course_params
    params.require(:course).permit(:starts_at, :ends_at)
  end
end
