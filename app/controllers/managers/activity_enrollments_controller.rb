class Managers::ActivityEnrollmentsController < ApplicationController
  def destroy
    @activity_enrollment = ActivityEnrollment.find(params[:id])
    authorize([:managers, @activity_enrollment])
    @activity_enrollment.destroy
    redirect_to managers_activity_path(@activity_enrollment.activity)
    flash[:notice] = "Elève retiré de l'activité"
  end
end
