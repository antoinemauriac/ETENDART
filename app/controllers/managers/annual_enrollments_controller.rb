class Managers::AnnualEnrollmentsController < ApplicationController
  def create
    @student = Student.find(params[:student_id])
    authorize([:managers, @student], policy_class: Managers::AnnualEnrollmentPolicy)

    academy = Academy.find(params[:academy])
    @student.academies << academy unless @student.academies.include?(academy)

    annual_program = AnnualProgram.find(params[:annual_program])
    @student.annual_programs << annual_program unless @student.annual_programs.include?(annual_program)

    activity = Activity.find(params[:activity])
    if @student.activities.include?(activity)
      redirect_to managers_student_path(@student)
      flash[:alert] = "L'élève est déjà inscrit à cette activité"
    else
      @student.courses << activity.courses
      @student.activities << activity
      redirect_to managers_student_path(@student)
      flash[:notice] = "Inscription validée"
    end
  end

  def update_annual_programs
    academy = Academy.find(params[:academy_id])
    authorize([:managers, academy], policy_class: Managers::AnnualEnrollmentPolicy)
    annual_programs = academy.annual_programs
    render json: annual_programs.select(:id, :start_year, :end_year)
  end

  def update_activities
    annual_program = AnnualProgram.find(params[:annual_program_id])
    authorize([:managers, annual_program], policy_class: Managers::AnnualEnrollmentPolicy)
    activities = annual_program.activities
    render json: activities.select(:id, :name)
  end
end
