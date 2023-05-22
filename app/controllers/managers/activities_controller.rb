class Managers::ActivitiesController < ApplicationController
  before_action :camp, only: %i[new create]

  def new
    @activity = Activity.new
    @school_period = camp.school_period
    @academy = @school_period.academy
    @locations = @academy.locations
    authorize([:managers, Activity.new])
  end

  def create
    @activity = camp.activities.build(activity_params)
    @academy = camp.academy
    @locations = @academy.locations
    @school_period = camp.school_period
    authorize([:managers, @activity])

    days = params[:activity][:days][:day_of_week].reject { |day| day == "0" }
    coach = User.find_by_id(params[:activity][:coach_id])
    coaches = params[:activity][:coach_ids].reject { |id| id == params[:activity][:coach_id] || id == "" }
    # @activity.coaches << coach if coach
    @activity.coaches << User.where(id: coaches) if coaches.any?

    if @activity.errors.any?
      return render :new, status: :unprocessable_entity
    end

    if validate_start_time_before_end_time
      if @activity.save
        create_courses_for_activity(@activity, coach, days)

        redirect_to managers_camp_path(@camp), notice: "Activité créée"
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
    @academy = @activity.academy
    @camp = @activity.camp
    @school_period = @camp.school_period
    @students = @activity.students.sort_by(&:last_name)
    authorize([:managers, @activity], policy_class: Managers::ActivityPolicy)
    @courses = @activity.courses.sort_by(&:starts_at)
    category = @activity.category
    @coach = @activity.lead_coach
    @coaches = category.coaches.joins(:coach_academies).where(coach_academies: { academy_id: @academy.id })
  end

  def update
    @activity = Activity.find(params[:id])
    authorize([:managers, @activity])

    if @activity.update(activity_params)
      # mettre à jour la liste des coaches
      coach = User.find_by_id(params[:activity][:coach_id])
      coaches = params[:activity][:coach_ids].reject { |id| id == "" }
      @activity.coaches = []
      # @activity.coaches << coach if coach
      @activity.coaches << User.where(id: coaches) if coaches.any?

      # update le coach de tous les courses
      @activity.courses.each do |course|
        course.update(coach: coach)
      end
      redirect_to managers_activity_path(@activity), notice: "L'activité a été mise à jour avec succès."
    else
      flash.now[:alert] = "Erreur lors de la mise à jour de l'activité."
      render :show
    end
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
    params.require(:activity).permit(:name, :category_id, :coach_id, :location_id)
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
  def create_courses_for_activity(activity, coach, days)
    days.each do |day|
      start_time = Time.parse(params[:activity][:days]["start_time_#{day}"])
      end_time = Time.parse(params[:activity][:days]["end_time_#{day}"])
      date = find_date_for_day(day)

      start_datetime = Time.zone.local(date.year, date.month, date.day, start_time.hour, start_time.min, start_time.sec)
      end_datetime = Time.zone.local(date.year, date.month, date.day, end_time.hour, end_time.min, end_time.sec)

      Course.create!(activity: activity, starts_at: start_datetime, ends_at: end_datetime, manager: current_user, coach: coach)
    end
  end

  def find_date_for_day(day)
    day_names_fr = ['Dimanche', 'Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi']
    date = @camp.starts_at
    while day_names_fr[date.strftime("%w").to_i] != day.capitalize
      date += 1
    end
    date
  end
end
