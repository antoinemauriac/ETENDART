class Managers::ActivitiesController < ApplicationController
  before_action :camp, only: %i[new create]

  def new
    @activity = Activity.new
    @school_period = camp.school_period
    @academy = @school_period.academy
    @locations = @academy.locations
    authorize([:managers, @activity])
  end

  def new_for_annual
    @activity = Activity.new
    @annual_program = AnnualProgram.find(params[:annual_program])
    @academy = @annual_program.academy
    @coaches = @academy.coaches
    @locations = @academy.locations
    authorize([:managers, @activity])
  end

  def create
    activity = camp.activities.build(activity_params)
    academy = camp.academy

    authorize([:managers, activity])

    days = params[:activity][:days][:day_of_week].reject { |day| day == "0" }
    coach = User.find(params[:activity][:coach_id])
    coaches = params[:activity][:coach_ids].reject { |id| id == params[:activity][:coach_id] || id == "" }

    activity.coaches << User.where(id: coaches) if coaches.any?
    activity.coaches << coach if coach

    if activity.errors.any?
      return render :new, status: :unprocessable_entity
    end

    if validate_start_time_before_end_time
      if activity.save
        activity.update(annual: false)
        create_courses_for_activity(activity, coach, days)

        redirect_to managers_camp_path(camp), notice: "Activité créée"
      else
        flash[:alert] = "Une erreur est survenue"
        render :new, status: :unprocessable_entity
      end
    else
      flash[:alert] = "L'heure de début doit être avant l'heure de fin"
      render :new, status: :unprocessable_entity
    end
  end

  def create_for_annual
    annual_program = AnnualProgram.find(params[:annual_program])
    activity = annual_program.activities.build(activity_params)

    coach = User.find_by_id(params[:activity][:coach_id])
    coaches = params[:activity][:coach_ids].reject { |id| id == params[:activity][:coach_id] || id == "" }

    activity.coaches << User.where(id: coaches) if coaches.any?
    activity.coaches << coach if coach

    authorize([:managers, activity])
    if activity.save
      activity.update(annual: true)
      create_annual_courses_for_activity(params, activity, annual_program, coach)
      redirect_to managers_annual_program_path(annual_program), notice: "Activité créée"
    else
      flash[:alert] = "Une erreur est survenue"
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @activity = Activity.find(params[:id])
    @academy = @activity.academy
    @camp = @activity.camp
    @school_period = @camp.school_period
    # @students = @activity.students_with_next_activity_enrollments.sort_by(&:last_name)
    @students = @activity.students.sort_by(&:last_name)
    authorize([:managers, @activity], policy_class: Managers::ActivityPolicy)
    @courses = @activity.courses.sort_by(&:starts_at)
    category = @activity.category
    @coach = @activity.coach
    @coaches = category.coaches.joins(:coach_academies).where(coach_academies: { academy_id: @academy.id })
  end

  def show_for_annual
    @activity = Activity.find(params[:id])
    @academy = @activity.academy
    @annual_program = @activity.annual_program
    # @students = @activity.students_with_next_activity_enrollments.sort_by(&:last_name)
    @students = @activity.students.sort_by(&:last_name)
    authorize([:managers, @activity], policy_class: Managers::ActivityPolicy)
    @courses = @activity.next_courses.sort_by(&:starts_at).first(3)
    category = @activity.category
    @coach = @activity.coach
    @coaches = category.coaches.joins(:coach_academies).where(coach_academies: { academy_id: @academy.id })
  end

  def all_annual_courses
    @activity = Activity.find(params[:id])
    @courses = @activity.courses.sort_by(&:starts_at)
    @academy = @activity.academy
    @annual_program = @activity.annual_program
    authorize([:managers, @activity], policy_class: Managers::ActivityPolicy)
  end

  def update
    @activity = Activity.find(params[:id])
    authorize([:managers, @activity])

    if @activity.update(activity_params)

      coach = User.find_by_id(params[:activity][:coach_id])
      coaches = params[:activity][:coach_ids].reject { |id| id == "" }
      @activity.coaches.clear

      @activity.coaches << User.where(id: coaches) if coaches.any?
      @activity.coaches << coach if coach

      @activity.courses.each do |course|
        course.update(coach: coach)
      end
      if params[:redirect_to] == "camp"
        redirect_to managers_activity_path(@activity), notice: "L'activité a été mise à jour avec succès."
      else
        redirect_to show_for_annual_managers_activity_path(@activity), notice: "L'activité a été mise à jour avec succès."
      end
    else
      flash.now[:alert] = "Erreur lors de la mise à jour de l'activité."
      if params[:redirect_to] == "camp"
        render :show
      else
        render :show_for_annual
      end
    end
  end

  def destroy
    activity = Activity.find(params[:id])
    authorize([:managers, activity])
    activity.destroy
    if activity.camp
    redirect_to managers_camp_path(activity.camp)
    flash[:notice] = "Activité supprimée"
    else
      redirect_to managers_annual_program_path(activity.annual_program)
      flash[:notice] = "Activité supprimée"
    end
  end

  def export_activity_students
    activity = Activity.find(params[:activity])
    authorize([:managers, activity])
    students = activity.students.sort_by(&:last_name)
    respond_to do |format|
      format.csv do
        headers['Content-Type'] = 'text/csv; charset=UTF-8'
        headers['Content-Disposition'] = "attachment; filename=liste_élèves_#{activity.name}.csv"

        csv_data = CSV.generate(col_sep: ';', encoding: 'UTF-8') do |csv|
          csv << ["Activité", "Nom", "Prénom", "Genre", "Age", "Telephone", "Email"]

          students.each do |student|
            csv << [activity.name, student.last_name, student.first_name, student.gender, student.age, student.phone_number, student.email]
          end
        end

        send_data(csv_data, filename: "liste_élèves_#{activity.name}.csv")
      end
    end
  end


  private

  def activity_params
    params.require(:activity).permit(:name, :category_id, :coach_id, :location_id)
  end

  def camp
    @camp ||= Camp.find(params[:camp])
  end

  def validate_start_time_before_end_time
    no_error = true
    Activity::DAYS.each do |day, times|
      start_time = Time.parse(params[:activity][:days]["start_time_#{day}"])
      end_time = Time.parse(params[:activity][:days]["end_time_#{day}"])

      next unless start_time && end_time

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

      Course.create!(activity: activity, starts_at: start_datetime, ends_at: end_datetime, manager: current_user, coach: coach, annual: false)
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

  def create_annual_courses_for_activity(params, activity, annual_program, coach)
    start_time_str = params[:activity][:day_attributes]["start_time(4i)"] + ":" + params[:activity][:day_attributes]["start_time(5i)"]
    end_time_str = params[:activity][:day_attributes]["end_time(4i)"] + ":" + params[:activity][:day_attributes]["end_time(5i)"]

    specific_days = annual_program.find_all_specific_days(params[:activity][:day_attributes][:day])

    specific_days.each do |day|
      start_time = Time.zone.parse("#{day} #{start_time_str}")
      end_time = Time.zone.parse("#{day} #{end_time_str}")
      Course.create(activity: activity, starts_at: start_time, ends_at: end_time, manager: current_user, coach: coach, annual: true)
    end
  end
end
