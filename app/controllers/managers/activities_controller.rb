class Managers::ActivitiesController < ApplicationController
  before_action :camp, only: %i[new create]
  before_action :set_cache_headers, only: %i[show show_for_annual]

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
    @academy = camp.academy
    school_period = camp.school_period

    authorize([:managers, activity])

    days = params[:activity][:days][:day_of_week].reject { |day| day == "0" }
    coach = User.find(params[:activity][:coach_id]) if params[:activity][:coach_id].present?
    coaches_ids = params[:activity][:coach_ids].reject { |id| id == params[:activity][:coach_id] || id == "" }
    coaches = User.where(id: coaches_ids)

    ActiveRecord::Base.transaction do
      activity.coaches << coaches if coaches.any?
      activity.coaches << coach if coach

      coaches.each do |coach|
        camp.coaches << coach unless camp.coaches.include?(coach)
      end
      camp.coaches << coach if coach && !camp.coaches.include?(coach)


      if validate_courses
        if activity.save
          activity.activity_stat = ActivityStat.create(activity: activity)
          create_courses_for_activity(activity, coach, days)
          redirect_to managers_camp_path(camp), notice: "Activité créée"
        else
          flash[:alert] = "Erreur : #{activity.errors.full_messages.join(', ')}"
          redirect_to new_managers_activity_path(camp: camp, school_period: school_period)
        end
      else
        flash[:alert] = "L'heure de début doit être avant l'heure de fin"
        redirect_to new_managers_activity_path(camp: camp, school_period: school_period)
      end
    end
  end

  def create_for_annual
    annual_program = AnnualProgram.find(params[:annual_program])
    activity = annual_program.activities.build(activity_params)
    authorize([:managers, activity])

    coach = User.find_by_id(params[:activity][:coach_id])
    coaches = params[:activity][:coach_ids].reject { |id| id == params[:activity][:coach_id] || id == "" }

    ActiveRecord::Base.transaction do
      activity.coaches << User.where(id: coaches) if coaches.any?
      activity.coaches << coach if coach

      if validate_annual_courses
        if activity.save
          activity.update(annual: true)
          activity.activity_stat = ActivityStat.create(activity: activity)
          create_annual_courses_for_activity(params, activity, annual_program, coach)
          redirect_to managers_annual_program_path(annual_program), notice: "Activité créée"
        else
          flash[:alert] = "Erreur : #{activity.errors.full_messages.join(', ')}"
          redirect_to new_for_annual_managers_activity_path(annual_program: annual_program, academy: annual_program.academy)
        end
      else
        flash[:alert] = "L'heure de début doit être avant l'heure de fin"
        redirect_to new_for_annual_managers_activity_path(annual_program: annual_program, academy: annual_program.academy)
      end
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
    @last_course = @activity.courses.max_by(&:starts_at)
    @last_course_day = AnnualProgram::DAY_EN_TO_FR[@last_course.starts_at.strftime('%A')] if @last_course
    @last_course_start_time = @last_course.starts_at.to_time if @last_course
    @last_course_end_time = @last_course.ends_at.to_time if @last_course
    # @students = @activity.students_with_next_activity_enrollments.sort_by(&:last_name)
    @students = @activity.students.sort_by(&:last_name)
    authorize([:managers, @activity], policy_class: Managers::ActivityPolicy)
    if @activity.next_courses.size >= 5
      @courses = @activity.next_courses.sort_by(&:starts_at).first(5)
    else
      @courses = @activity.courses.sort_by(&:starts_at).last(5)
    end
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
    activity = Activity.find(params[:id])
    authorize([:managers, activity])
    camp = activity.camp
    annual_program = activity.annual_program

    if camp
      activity.coaches.each do |coach|
        activities = coach.activities.where(camp: activity.camp)
        if activities.count == 1
          camp.coaches.delete(coach)
        end
      end
    end

    if activity.update(activity_params)

      coach = User.find_by_id(params[:activity][:coach_id])
      coaches_ids = params[:activity][:coach_ids].reject { |id| id == "" }
      coaches = User.where(id: coaches_ids)

      activity.coaches.clear
      activity.coaches << coaches if coaches.any?
      activity.coaches << coach if coach

      if camp
        coaches.each do |coach|
          camp.coaches << coach unless camp.coaches.include?(coach)
        end
        camp.coaches << coach if coach && !camp.coaches.include?(coach)
      end

      if annual_program
        update_annual_courses(activity, params)
      end

      activity.next_courses.each do |course|
        course.update(coach: coach)
      end
      if params[:redirect_to] == "camp"
        redirect_to managers_activity_path(activity), notice: "L'activité a été mise à jour avec succès."
      else
        redirect_to show_for_annual_managers_activity_path(activity), notice: "L'activité a été mise à jour avec succès."
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

        csv_data = CSV.generate(col_sep: ';', encoding: 'UTF-8') do |csv|
          csv << ["Activité", "Nom", "Prénom", "Genre", "Date de naissance", "Age", "Telephone", "Email"]

          students.each do |student|
            csv << [activity.name, student.last_name, student.first_name, student.gender, student.date_of_birth, student.age, student.phone_number, student.email]
          end
        end

        if activity.camp
          filename = "#{activity.camp.academy.name}_#{activity.school_period.name}_#{activity.camp.name}_#{activity.name}.csv"
        else
          filename = "#{activity.annual_program.academy.name}_#{activity.annual_program.name}_#{activity.name}.csv"
        end
        send_data(csv_data, filename: filename)
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

  def validate_courses
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

  def validate_annual_courses
    no_error = true
    start_time = Time.zone.parse("#{params[:activity][:day_attributes]["start_time(4i)"]}:#{params[:activity][:day_attributes]["start_time(5i)"]}")
    end_time = Time.zone.parse("#{params[:activity][:day_attributes]["end_time(4i)"]}:#{params[:activity][:day_attributes]["end_time(5i)"]}")

    if start_time >= end_time
      no_error = false
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

  def update_annual_courses(activity, params)
    new_day = params[:activity][:day_attributes][:day]
    new_day_number = AnnualProgram::DAY_TO_WDAY[new_day]

    start_time_str = params[:activity][:day_attributes]["start_time(4i)"] + ":" + params[:activity][:day_attributes]["start_time(5i)"]
    end_time_str = params[:activity][:day_attributes]["end_time(4i)"] + ":" + params[:activity][:day_attributes]["end_time(5i)"]

    activity.next_courses.each do |course|
      # Ajuster le jour
      day_difference = new_day_number - course.starts_at.wday
      new_start_date = course.starts_at + day_difference.days
      new_end_date = course.ends_at + day_difference.days

      # Ajuster l'heure
      new_start_time = new_start_date.change(hour: start_time_str.split(':')[0].to_i, min: start_time_str.split(':')[1].to_i)
      new_end_time = new_end_date.change(hour: end_time_str.split(':')[0].to_i, min: end_time_str.split(':')[1].to_i)

      course.update(starts_at: new_start_time, ends_at: new_end_time)
    end
  end

  def set_cache_headers
    response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "0"
  end
end
