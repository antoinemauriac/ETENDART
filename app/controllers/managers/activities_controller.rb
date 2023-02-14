class Managers::ActivitiesController < ApplicationController
  def new
    @activity = Activity.new
    @camp = Camp.find(params[:camp_id])
  end

  def create
    @activity = Activity.new(activity_params)
    @camp = Camp.find(params[:camp_id])
    @activity.camp = @camp
    if @activity.save
      redirect_to managers_activity_path(@activity)
      flash[:notice] = "Activité créée"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
  def activity_params
    params.require(:activity).permit(:name, :category_id, :coach_id, courses_attributes: [:id, :starts_at, :ends_at])
  end
end
