class Managers::AcademiesController < ApplicationController

  def index
    @academies = current_user.academies_as_manager
    skip_policy_scope
    authorize [:managers, @academies]
  end


  def show
    @academy = Academy.find(params[:id])
    authorize [:managers, @academy]
    @course = Course.first

    @feedbacks = Feedback.last_five(@academy)

    @today_courses = @academy.today_courses
    @tomorrow_courses = @academy.tomorrow_courses

    @camp = @academy.camps.where("starts_at <= ? AND ends_at >= ?", Time.current, Time.current).first
    if @camp.present? && @academy.banished
      @banished_students = @camp.banished_students.sort_by { |student| student.camp_enrollments.find_by(camp: @camp)&.banishment_day }.reverse
    end
    @today_absent_students = @academy.today_absent_students.first(5) if @camp.present?

    @annual_program = @academy.annual_programs.select { |annual_program| annual_program.starts_at <= Time.current && annual_program.ends_at >= Time.current }.first
    if @annual_program.present?
      @week_absent_enrollments = @annual_program.week_absent_enrollments_sorted_by_day.first(5)
    end
    @old_presence_sheet = @academy.old_presence_sheet if @camp
    @old_presence_sheet = @annual_program.old_presence_sheet if @annual_program

  end

  def export_absent_students_csv
    academy = Academy.find(params[:id])
    authorize [:managers, academy]
    today_absent_students = academy.today_absent_students
    respond_to do |format|
      format.csv do

        headers['Content-Type'] = 'text/csv; charset=UTF-8'
        headers['Content-Disposition'] = 'attachment; filename=eleves_absents.csv'

        csv_data = CSV.generate(col_sep: ';', encoding: 'UTF-8') do |csv|
          csv << ["Nom", "Prénom", "Genre", "Telephone", "Email"]

          today_absent_students.each do |student|
            csv << [student.last_name, student.first_name, student.gender, student.phone_modified, student.email]
          end
        end

        send_data(csv_data, filename: "eleves_absents_aujourd'hui.csv")
      end
    end
  end

  def export_week_absent_students_csv
    academy = Academy.find(params[:id])
    authorize [:managers, academy]
    annual_program = academy.annual_programs.select { |annual_program| annual_program.starts_at <= Time.current && annual_program.ends_at >= Time.current }.first
    week_absent_enrollments = annual_program.week_absent_enrollments_sorted_by_day
    respond_to do |format|
      format.csv do

        headers['Content-Type'] = 'text/csv; charset=UTF-8'
        headers['Content-Disposition'] = 'attachment; filename=eleves_absents.csv'

        csv_data = CSV.generate(col_sep: ';', encoding: 'UTF-8') do |csv|
          csv << ["Jour", "Activité", "Nom", "Prénom", "Genre", "Telephone", "Email"]

          week_absent_enrollments.each do |enrollment|
            student = enrollment.student
            csv << [l(enrollment.course.starts_at, format: :day_name), enrollment.activity.name, student.last_name, student.first_name, student.gender, student.phone_modified, student.email]
          end
        end

        send_data(csv_data, filename: "eleves_absents_semaine.csv")
      end
    end
  end

  def today_absent_students
    @academy = Academy.find(params[:id])
    authorize [:managers, @academy]
    @absent_students = @academy.today_absent_students
  end

  def week_absent_students
    @academy = Academy.find(params[:id])
    authorize [:managers, @academy]
    @annual_program = @academy.annual_programs.select { |annual_program| annual_program.starts_at <= Time.current && annual_program.ends_at >= Time.current }.first
    @week_absent_enrollments = @annual_program.week_absent_enrollments_sorted_by_day
  end

  private

  def academy_params
    params.require(:academy).permit(:name)
  end

end
