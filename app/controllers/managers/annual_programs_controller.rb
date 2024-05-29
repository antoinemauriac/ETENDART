class Managers::AnnualProgramsController < ApplicationController
  def index
    @academy = Academy.find(params[:academy])
    @annual_programs = @academy.annual_programs
    skip_policy_scope
    authorize [:managers, @annual_programs]
  end

  def index_for_admin
    @annual_programs = AnnualProgram.all.where(new: true).group_by { |annual_program| annual_program.starts_at.year }
    skip_policy_scope
    authorize [:managers, :annual_program]
  end

  def new
    @academy = Academy.find(params[:academy])
    @annual_program = AnnualProgram.new
    @annual_program.academy = @academy
    authorize [:managers, @annual_program]

    current_year = Date.today.year
    next_year = current_year + 1

    program_periods_defaults = [
      { start_date: Date.parse("25/09/#{current_year}"), end_date: Date.parse("20/10/#{current_year}") },
      { start_date: Date.parse("30/10/#{current_year}"), end_date: Date.parse("15/12/#{current_year}") },
      { start_date: Date.parse("08/01/#{next_year}"), end_date: Date.parse("16/02/#{next_year}") },
      { start_date: Date.parse("04/03/#{next_year}"), end_date: Date.parse("12/04/#{next_year}") },
      { start_date: Date.parse("22/04/#{next_year}"), end_date: Date.parse("14/06/#{next_year}") }
    ]

    @default_program_periods = program_periods_defaults.map do |period_params|
      ProgramPeriod.new(period_params)
    end
  end

  def create
    academy = Academy.find(params[:academy])

    annual_program = academy.annual_programs.build(annual_program_params)
    annual_program.update(starts_at: annual_program.program_periods.first.start_date)
    annual_program.update(ends_at: annual_program.program_periods.last.end_date)
    annual_program.annual_program_stat = AnnualProgramStat.create(annual_program: annual_program)
    authorize [:managers, annual_program]

    if annual_program.save
      redirect_to managers_annual_program_path(annual_program), notice: 'Le programme annuel a été créé avec succès.'
    else
      error_messages = annual_program.errors.full_messages.join(', ')
      redirect_to new_managers_annual_program_path(academy: academy), alert: "#{error_messages}"
    end
  end

  def show
    @annual_program = AnnualProgram.find(params[:id])
    @academy = @annual_program.academy
    authorize [:managers, @annual_program]
    @activities = @annual_program.active_sorted_activities
    @students = @annual_program.students.order(:last_name)
  end

  def destroy
    annual_program = AnnualProgram.find(params[:id])
    academy = annual_program.academy
    authorize [:managers, annual_program]
    annual_program.destroy
    redirect_to managers_annual_programs_path(academy: academy)
    flash[:notice] = "Activité supprimée"
  end

  def export_past_enrollments
    annual_program = AnnualProgram.find(params[:id])
    authorize [:managers, annual_program]
    past_course_enrollments = annual_program.past_course_enrollments
    respond_to do |format|
      format.csv do

        csv_data = CSV.generate(col_sep: ';', encoding: 'UTF-8') do |csv|
          csv << ["Semaine", "Jour", "Heure", "Activité", "Nom", "Prénom", "Genre", "Date de naissance", "Age", "Telephone", "Email", "Presence"]

          past_course_enrollments.each do |enrollment|
            student = enrollment.student
            csv << [l(enrollment.course.starts_at, format: :week), l(enrollment.course.starts_at, format: :date), l(enrollment.course.starts_at, format: :hour_min), enrollment.activity.name, student.last_name, student.first_name, student.gender, student.date_of_birth, student.age, student.phone_number, student.email, enrollment.present ? "present" : "absent"]
          end
        end

        send_data(csv_data, filename: "#{annual_program.academy.name}_#{annual_program.name}_feuilles_de_présence.csv")
      end
    end
  end

  def export_annual_students
    annual_program = AnnualProgram.find(params[:id])
    authorize [:managers, annual_program]
    students = annual_program.students
    respond_to do |format|
      format.csv do

        csv_data = CSV.generate(col_sep: ';', encoding: 'UTF-8') do |csv|
          csv << ["Académie", "Programme", "Nom", "Prénom", "Genre", "Droit à l'image", "Date de naissance", "Age", "Telephone", "Email"]

          students.each do |student|
            annual_program_enrollment = student.annual_program_enrollments.find_by(annual_program: annual_program)
            image_consent = annual_program_enrollment.image_consent ? "Oui" : "Non"
            csv << [annual_program.academy.name, annual_program.name, student.last_name, student.first_name, student.gender, image_consent, student.date_of_birth, student.age, student.phone_number, student.email]
          end
        end

        send_data(csv_data, filename: "#{annual_program.academy.name}_#{annual_program.name}_élèves.csv")
      end
    end
  end

  def statistics
    @annual_program = AnnualProgram.find(params[:id])
    authorize [:managers, @annual_program]
    @academy = @annual_program.academy
    @activities = @annual_program.sorted_activities

    @annual_program_stat = @annual_program.annual_program_stat

    @sorted_departments = @annual_program_stat.participant_departments

    @category_ids = @annual_program_stat.category_ids
  end

  private

  def annual_program_params
    params.require(:annual_program).permit(program_periods_attributes: [:id, :start_date, :end_date, :_destroy])
  end
end
