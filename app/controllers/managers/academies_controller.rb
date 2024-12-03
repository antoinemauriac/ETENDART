class Managers::AcademiesController < ApplicationController

  def show
    @academy = Academy.find(params[:id])
    authorize [:managers, @academy]
    @course = Course.first

    @feedbacks = Feedback.includes(:student, :coach).includes(:coach).last_five(@academy)

    @today_courses = @academy.today_courses
    @tomorrow_courses = @academy.tomorrow_courses

    @camp = @academy.camps.where("starts_at <= ? AND ends_at >= ?", Time.current, Time.current - 2.day).first
    # if @camp.present? && @academy.banished
    #   @banished_students = @camp.banished_students.sort_by { |student| [-student.camp_enrollments.find_by(camp: @camp)&.banishment_day.to_i, student.last_name] }
    # end
    @today_absent_students = @academy.today_absent_students.first(5) if @camp.present?

    @annual_program = @academy.annual_programs.select { |annual_program| annual_program.starts_at <= Time.current && annual_program.ends_at >= Time.current - 2.day }.first
    if @annual_program.present?
      @week_absent_enrollments = @annual_program.week_absent_enrollments_sorted_by_day.first(5)
    end

    @old_presence_sheet = @academy.old_presence_sheet
    if @annual_program.present?
      @old_presence_sheet = @old_presence_sheet + @annual_program.old_presence_sheet
    end
  end

  def export_absent_students_csv
    academy = Academy.find(params[:id])
    authorize [:managers, academy]
    today_absent_students = academy.today_absent_students
    respond_to do |format|
      format.csv do

        csv_data = CSV.generate(col_sep: ';', encoding: 'UTF-8') do |csv|
          csv << ["Nom", "Prénom", "Genre", "Date de naissance", "Age", "Telephone", "Email"]

          today_absent_students.each do |student|
            csv << [student.last_name, student.first_name, student.gender, student.date_of_birth, student.age, student.phone_number, student.email]
          end
        end

        today = I18n.l(Time.current, format: :date_reverse)

        send_data(csv_data, filename: "#{academy.name}_#{today}_eleves_absents.csv")
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

        csv_data = CSV.generate(col_sep: ';', encoding: 'UTF-8') do |csv|
          csv << ["Jour", "Activité", "Nom", "Prénom", "Genre", "Date de naissance", "Age", "Telephone", "Email"]

          week_absent_enrollments.each do |enrollment|
            student = enrollment.student
            csv << [l(enrollment.course.starts_at, format: :day_name), enrollment.activity.name, student.last_name, student.first_name, student.gender, student.date_of_birth, student.age, student.phone_number, student.email]
          end
        end

        week = I18n.l(Time.current, format: :week)

        send_data(csv_data, filename: "#{academy.name}_#{week}_eleves_absents.csv")
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
