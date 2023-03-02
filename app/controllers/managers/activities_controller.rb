class Managers::ActivitiesController < ApplicationController
  before_action :camp, only: %i[new create]

  def new
    @activity = Activity.new
    authorize([:managers, Activity.new])
  end

  def create
    @activity = camp.activities.build(activity_params)
    authorize([:managers, @activity])
    days = params[:activity][:days][:day_of_week].reject { |day| day == "0" }
    coach = User.find(params[:activity][:coach_id])

    # Validate start time and end time
    # # A mettre dans le modèle

    # Plus besoin de ceci car le modèle va se charger de remonter l'erreur dans if @activity.save
    if @activity.errors.any?
      return render :new, status: :unprocessable_entity
    end

    if validate_start_time_before_end_time
      if @activity.save
        coach.camps << @camp unless coach.camps.include?(@camp)
        days.each do |day|
          start_time = Time.parse(params[:activity][:days]["start_time_#{day}"])
          end_time = Time.parse(params[:activity][:days]["end_time_#{day}"])

          # Trouver la date correspondant au jour de la semaine donné
          date = @camp.starts_at
          while date.strftime("%A").downcase != day.downcase
            date += 1
          end

          # Calculer la date et heure de début et de fin en utilisant les dates starts_at et ends_at du camp
          start_datetime = DateTime.new(date.year, date.month, date.day, start_time.hour, start_time.min, start_time.sec, start_time.utc_offset)
          end_datetime = DateTime.new(date.year, date.month, date.day, end_time.hour, end_time.min, end_time.sec, end_time.utc_offset)

          Course.create!(activity: @activity, starts_at: start_datetime, ends_at: end_datetime, manager: current_user, coach: coach)
        end

        redirect_to managers_camp_path(@camp)
        flash[:notice] = "Activité créée"
      else
        flash[:alert] = "Une erreur est survenue"
        render :new, status: :unprocessable_entity
      end
    else
      flash[:alert] = "L'heure de début doit être avant l'heure de fin"
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @activity = Activity.find(params[:id])
    authorize([:managers, @activity], policy_class: Managers::ActivityPolicy)
    @courses = @activity.courses.sort_by(&:starts_at)
  end

  def destroy
    activity = Activity.find(params[:id])
    authorize([:managers, activity])
    activity.destroy
    redirect_to managers_camp_path(activity.camp)
    flash[:notice] = "Activité supprimée"
  end

  private

  def activity_params
    params.require(:activity).permit(:name, :category_id, :coach_id)
  end

  def camp
    @camp ||= Camp.find(params[:camp_id])
  end

  # Les validations sont plutôt à ajouter dans le modèle si elles sont toujours appliqués
  def validate_start_time_before_end_time
    no_error = true
    Activity::DAYS.each do |day, times|
      start_time = Time.parse(params[:activity][:days]["start_time_#{day}"])
      end_time = Time.parse(params[:activity][:days]["end_time_#{day}"])

      # Vérifier que les temps de début et de fin sont tous les deux présents
      next unless start_time && end_time

      # Vérifier que le temps de début est inférieur au temps de fin
      if start_time >= end_time
        no_error = false
      end
    end
    no_error
  end
end
