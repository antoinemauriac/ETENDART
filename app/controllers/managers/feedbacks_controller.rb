class Managers::FeedbacksController < ApplicationController
  def new
    @student = Student.find(params[:student_id])
    authorize([:managers, @student], policy_class: Managers::FeedbackPolicy)
    @feedback = Feedback.new
  end

  def create
    @student = Student.find(params[:feedback][:student_id])
    authorize([:managers, @student], policy_class: Managers::FeedbackPolicy)
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

  private

  def feedback_params
    params.require(:feedback).permit(:content)
  end
end
