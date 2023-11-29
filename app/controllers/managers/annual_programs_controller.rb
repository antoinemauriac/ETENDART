class Managers::AnnualProgramsController < ApplicationController

  def index
    @academy = Academy.find(params[:academy])
    @annual_programs = @academy.annual_programs
    skip_policy_scope
    authorize [:managers, @annual_programs]
  end

  def new
    # raise
    @academy = Academy.find(params[:academy])
    @annual_program = AnnualProgram.new
    @annual_program.academy = @academy
    authorize [:managers, @annual_program]

    program_periods_defaults = [
      { start_date: Date.parse('25/09/2023'), end_date: Date.parse('20/10/2023') },
      { start_date: Date.parse('30/10/2023'), end_date: Date.parse('15/12/2023') },
      { start_date: Date.parse('08/01/2024'), end_date: Date.parse('16/02/2024') },
      { start_date: Date.parse('04/03/2024'), end_date: Date.parse('12/04/2024') },
      { start_date: Date.parse('22/04/2024'), end_date: Date.parse('14/06/2024') }
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
    @activities = @annual_program.sorted_activities
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
        headers['Content-Type'] = 'text/csv; charset=UTF-8'
        headers['Content-Disposition'] = 'attachment; filename=feuille_presence.csv'

        csv_data = CSV.generate(col_sep: ';', encoding: 'UTF-8') do |csv|
          csv << ["Semaine", "Jour", "Heure", "Activité", "Nom", "Prénom", "Genre", "Telephone", "Email", "Presence"]

          past_course_enrollments.each do |enrollment|
            student = enrollment.student
            csv << [l(enrollment.course.starts_at, format: :week), l(enrollment.course.starts_at, format: :date), l(enrollment.course.starts_at, format: :hour_min), enrollment.activity.name, student.last_name, student.first_name, student.gender, student.phone_number, student.email, enrollment.present ? "present" : "absent"]
          end
        end

        send_data(csv_data, filename: "feuille_presence.csv")
      end
    end
  end

  def export_annual_students
    annual_program = AnnualProgram.find(params[:id])
    authorize [:managers, annual_program]
    students = annual_program.students
    respond_to do |format|
      format.csv do
        headers['Content-Type'] = 'text/csv; charset=UTF-8'
        headers['Content-Disposition'] = "attachment; filename=liste_élèves_#{annual_program.name}.csv"

        csv_data = CSV.generate(col_sep: ';', encoding: 'UTF-8') do |csv|
          csv << ["Académie", "Programme", "Nom", "Prénom", "Genre", "Age", "Telephone", "Email"]

          students.each do |student|
            csv << [annual_program.academy.name, annual_program.name, student.last_name, student.first_name, student.gender, student.age, student.phone_number, student.email]
          end
        end

        send_data(csv_data, filename: "liste_élèves_#{annual_program.name}.csv")
      end
    end
  end


  private

  def annual_program_params
    params.require(:annual_program).permit(program_periods_attributes: [:id, :start_date, :end_date, :_destroy])
  end
end
