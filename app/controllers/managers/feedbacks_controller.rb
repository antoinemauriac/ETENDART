class Managers::FeedbacksController < ApplicationController
  def new
    @student = Student.find(params[:student_id])
    authorize([:managers, @student], policy_class: Managers::FeedbackPolicy)
    @feedback = Feedback.new
  end

  def create
    @student = Student.find(params[:student_id])
    authorize([:managers, @student], policy_class: Managers::FeedbackPolicy)
    # academy_id = Academy.find(params[:academy_id])
    @feedback = Feedback.new(feedback_params)
    @feedback.student = @student
    @feedback.coach = current_user
    if @feedback.save
      redirect_to managers_student_path(@student)
      flash[:notice] = "Feedback ajouté avec succès"
    else
      flash[:alert] = "Une erreur est survenue"
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @feedback = Feedback.find(params[:id])
    authorize([:managers, @feedback], policy_class: Managers::FeedbackPolicy)
    @feedback.destroy
    redirect_to managers_student_path(@feedback.student)
    flash[:notice] = "Feedback supprimé avec succès"
  end

  private

  def feedback_params
    params.require(:feedback).permit(:content)
  end
end
