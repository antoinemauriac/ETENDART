class Managers::CoursesController < ApplicationController
  before_action :course, only: %i[edit show update destroy]

  def index
    @courses = current_user.courses_as_manager.sort_by(&:starts_at)
  end

  def show
    @enrollments = course.course_enrollments.joins(:student).order(last_name: :asc)
  end

  def edit; end

  def update
    if course.update(course_params)
      redirect_to managers_activity_path(course.activity)
      flash[:notice] = "Cours mis à jour"
    else
      flash[:alert] = course.errors.full_messages
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    course.destroy
    redirect_to managers_courses_path
    flash[:notice] = "Cours supprimé"
  end

  def update_enrollments
    enrollments_params = params[:enrollments]
    enrollments_params.each do |enrollment_params|
      enrollment = CourseEnrollment.find(enrollment_params[0].to_i)
      enrollment.update(present: enrollment_params[1][:present].to_i)
    end
    redirect_to managers_course_path(params[:id])
    flash[:notice] = "Appel mis à jour"
  end

  private

  def course
    @course ||= Course.find(params[:id])
  end

  def course_params
    params.require(:course).permit(:starts_at, :ends_at)
  end
end
