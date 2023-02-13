class Managers::ActivitiesController < ApplicationController
  def new
    @activity = Activity.new
    @activity.days.build
    @camp = Camp.find(params[:camp_id])
  end

  def create
    @activity = Activity.new(activity_params)
    @camp = Camp.find(params[:camp_id])
    @activity.camp = @camp
    if @activity.save
      redirect_to managers_camp_activity_path(@activity)
      flash[:notice] = "Activité créée"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private
  def activity_params
    params.require(:activity).permit(:name, :category_id, :coach_id, days: [:start_time, :end_time])
  end
end
