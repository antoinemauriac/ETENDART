class Managers::CoursesController < ApplicationController

  def index
    @courses = Course.where(manager: current_user).where('ends_at >= ?', 12.hours.ago).sort_by(&:starts_at)
  end

  def show
    @course = Course.find(params[:id])
    @enrollments = @course.course_enrollments.sort_by { |enrollment| enrollment.student.last_name }
  end

  def edit
    @course = Course.find(params[:id])
  end

  def update
    @course = Course.find(params[:id])
    if @course.update(course_params)
      redirect_to managers_course_path(@course)
      flash[:notice] = "Cours mis à jour"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @course = Course.find(params[:id])
    @course.destroy
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

  def course_params
    params.require(:course).permit(:starts_at, :ends_at)
  end
end
