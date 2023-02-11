class Managers::ActivitiesController < ApplicationController
  def show
    @activity = Activity.find(params[:id])
  end

  def new
    @activity = Activity.new
    @camp = Camp.find(params[:camp_id])
  end

  def create
#     days = ["Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi"]
# selected_days = []
# params[:activity][:days].each do |day, values|
#   if values["selected"] == "1"
#     start_time = Time.zone.parse("#{values["start_time"]["(4i)"]}:#{values["start_time"]["(5i)"]}")
#     end_time = Time.zone.parse("#{values["end_time"]["(4i)"]}:#{values["end_time"]["(5i)"]}")
#     selected_days << { day: day, start_time: start_time, end_time: end_time }
#   end
# end

    @activity = Activity.new(activity_params)
    @activity.camp = Camp.find(params[:camp_id])
    if @activity.save
      redirect_to managers_activity_path(@activity)
      flash[:notice] = "Activité crée"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def activity_params
    params.require(:activity).permit(:name, :category_id, :coach_id, :days, :min_capacity, :max_capacity)
  end
end
