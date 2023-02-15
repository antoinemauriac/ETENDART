class Managers::ActivitiesController < ApplicationController
  def new
    @activity = Activity.new
    @camp = Camp.find(params[:camp_id])
  end

  def create
    @activity = Activity.new(activity_params)
    @camp = Camp.find(params[:camp_id])
    @activity.camp = @camp
    starts_at = @camp.starts_at
    # ends_at = @camp.ends_at

    # Convertir les champs start_time et end_time pour chaque jour de la semaine

    # Définir une liste des noms de jours de la semaine en français
    days = params[:activity][:days][:day_of_week]

    if @activity.save
      days.each do |day|
        next if day == "0" # Ignorer les jours non sélectionnés

        # Convertir les champs start_time et end_time en objets Time
        start_time = Time.parse(params[:activity][:days]["start_time_#{day}"])
        end_time = Time.parse(params[:activity][:days]["end_time_#{day}"])

        # Trouver la date correspondant au jour de la semaine donné
        date = starts_at
        while date.strftime("%A").downcase != day.downcase
          date += 1
        end

        # Calculer la date et heure de début et de fin en utilisant les dates starts_at et ends_at du camp
        start_datetime = DateTime.new(date.year, date.month, date.day, start_time.hour, start_time.min, start_time.sec, start_time.utc_offset)
        end_datetime = DateTime.new(date.year, date.month, date.day, end_time.hour, end_time.min, end_time.sec, end_time.utc_offset)

        # Enregistrer les dates de début et de fin pour ce jour de la semaine
        Course.create!(activity: @activity, starts_at: start_datetime, ends_at: end_datetime, manager: current_user)
      end

      redirect_to managers_activity_path(@activity)
      flash[:notice] = "Activité créée"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @activity = Activity.find(params[:id])
    @courses = @activity.courses
  end


  private
  def activity_params
    params.require(:activity).permit(:name, :category_id, :coach_id, courses_attributes: [:id, :starts_at, :ends_at])
  end
end
