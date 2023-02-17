class Managers::ActivitiesController < ApplicationController
  def new
    @activity = Activity.new
    @camp = Camp.find(params[:camp_id])
  end

  def create
    @activity = Activity.new(activity_params)
    @camp = Camp.find(params[:camp_id])
    @activity.camp = @camp

    days = params[:activity][:days][:day_of_week].reject { |day| day == "0" }

    # Validate start time and end time
    validate_start_time_before_end_time

    if @activity.errors.any?
      render :new, status: :unprocessable_entity
      return
    end

    if @activity.save
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

        Course.create!(activity: @activity, starts_at: start_datetime, ends_at: end_datetime, manager: current_user)
      end

      redirect_to managers_camp_path(@camp)
      flash[:notice] = "Activité créée"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @activity = Activity.find(params[:id])
    @courses = @activity.courses.sort_by(&:starts_at)
  end

  private

  def activity_params
    params.require(:activity).permit(:name, :category_id, :coach_id)
  end

  def validate_start_time_before_end_time
    Activity::DAYS.each do |day, times|
      start_time = Time.parse(params[:activity][:days]["start_time_#{day}"])
      end_time = Time.parse(params[:activity][:days]["end_time_#{day}"])

      # Vérifier que les temps de début et de fin sont tous les deux présents
      next unless start_time && end_time

      # Vérifier que le temps de début est inférieur au temps de fin
      if start_time >= end_time
        @activity.errors.add(:base, "Le temps de début doit être avant le temps de fin pour le jour #{day}")
      end
    end
  end
end
