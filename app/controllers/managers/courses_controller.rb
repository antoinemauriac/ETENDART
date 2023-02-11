class Managers::CoursesController < ApplicationController

  def index
    @courses = Course.where(manager: current_user).where('ends_at >= ?', 12.hours.ago).sort_by(&:starts_at)
  end

  def show
    @course = Course.find(params[:id])
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


  private

  def course_params
    params.require(:course).permit(:starts_at, :ends_at)
  end
end
