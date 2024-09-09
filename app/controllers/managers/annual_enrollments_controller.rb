class Managers::AnnualEnrollmentsController < ApplicationController
  def create
    student = Student.find(params[:student_id])
    authorize([:managers, student], policy_class: Managers::AnnualEnrollmentPolicy)
    activity = Activity.find(params[:activity])
    if student.activities.include?(activity)
      redirect_to managers_student_path(student)
      flash[:alert] = "L'élève est déjà inscrit à cette activité"
    else
      academy = Academy.find(params[:academy])
      student.academies << academy unless student.academies.include?(academy)

      annual_program = AnnualProgram.find(params[:annual_program])
      student.annual_programs << annual_program unless student.annual_programs.include?(annual_program)

      image_consent = params[:image_consent]
      annual_program_enrollment = student.annual_program_enrollments.find_by(annual_program: annual_program)
      annual_program_enrollment.update(image_consent: image_consent)

      student.courses << activity.next_courses
      student.activities << activity

      start_year = annual_program.starts_at.year
      membership = student.memberships.find_by(start_year: start_year)
      if membership.nil?
        student.memberships.create(amount: 15, start_year: start_year, academy: academy)
      end
      redirect_to managers_student_path(student)
      flash[:notice] = "Inscription validée"
    end
  end

  def update_annual_programs
    academy = Academy.find(params[:academy_id])
    authorize([:managers, academy], policy_class: Managers::AnnualEnrollmentPolicy)
    annual_programs = academy.annual_programs.where('ends_at >= ?', Date.today).order(:starts_at)

    render json: annual_programs.as_json(only: [:id], methods: :name)
  end

  def update_activities
    annual_program = AnnualProgram.find(params[:annual_program_id])
    authorize([:managers, annual_program], policy_class: Managers::AnnualEnrollmentPolicy)
    activities = annual_program.activities.order(:name)
    render json: activities.select(:id, :name)
  end
end
