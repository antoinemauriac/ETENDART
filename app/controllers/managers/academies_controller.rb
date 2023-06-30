class Managers::AcademiesController < ApplicationController

  def index
    @academies = current_user.academies_as_manager
    skip_policy_scope
    authorize [:managers, @academies]
  end


  def show
    @academy = Academy.find(params[:id])
    authorize [:managers, @academy]

    @feedbacks = Feedback.last_five(@academy)
    @today_courses = @academy.today_courses
    @tomorrow_courses = @academy.tomorrow_courses
    @today_absent_students = @academy.today_absent_students.first(5)
    @camp = @academy.camps.where("starts_at <= ? AND ends_at >= ?", Time.current, Time.current).first
    if @camp.present?
      @banished_students = @camp.banished_students.sort_by { |student| student.camp_enrollments.find_by(camp: @camp)&.banishment_day }.reverse
    else
      @banished_students = []
    end
    @course = Course.first



    # @coaches = @academy.coaches

    # @locations = @academy.locations
    # @location = Location.new

    # @students = @academy.students
    # @camps = @academy.camps.where(starts_at: Date.today..Date.today + 1.year)
    # @school_period = SchoolPeriod.new
  end

  def export_absent_students_csv
    academy = Academy.find(params[:id])
    authorize [:managers, academy]
    today_absent_students = academy.today_absent_students
    respond_to do |format|
      format.csv do

        headers['Content-Type'] = 'text/csv; charset=UTF-8'
        headers['Content-Disposition'] = 'attachment; filename=eleves_exclus.csv'

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

  def all_absent_students
    @academy = Academy.find(params[:id])
    authorize [:managers, @academy]
    @absent_students = @academy.today_absent_students
  end

  private

  def academy_params
    params.require(:academy).permit(:name)
  end

end
