class Managers::CoachFeedbacksController < ApplicationController
  def create
    coach_feedback = CoachFeedback.new(coach_feedback_params)
    @coach = User.find(params[:coach])
    authorize([:managers, coach_feedback], policy_class: Managers::CoachFeedbackPolicy)
    coach_feedback.coach = @coach
    coach_feedback.manager = current_user
    if coach_feedback.save
      flash[:notice] = "Feedback ajouté avec succès."
      redirect_to managers_coach_path(@coach)
    else
      flash[:alert] = "Une erreur est survenue."
      redirect_to managers_coach_path(@coach)
    end
  end

  private

  def coach_feedback_params
    params.require(:coach_feedback).permit(:content)
  end
end
