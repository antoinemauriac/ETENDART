class Managers::AnnualEnrollmentsController < ApplicationController
  def create
    @student = Student.find(params[:student_id])
    authorize([:managers, @student], policy_class: Managers::AnnualEnrollmentPolicy)
    activity = Activity.find(params[:activity])
    if @student.activities.include?(activity)
      flash.now[:alert] = "L'élève est déjà inscrit à cette activité"

      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("flash-messages", partial: "shared/flashes") }
        format.html { redirect_to managers_student_path(@student), alert: flash[:alert] }
      end
    else
      academy = activity.academy
      @student.academies << academy unless @student.academies.include?(academy)

      annual_program = AnnualProgram.find(params[:annual_program])
      @student.annual_programs << annual_program unless @student.annual_programs.include?(annual_program)

      image_consent = params[:image_consent]
      annual_program_enrollment = @student.annual_program_enrollments.find_by(annual_program: annual_program)
      annual_program_enrollment.update(image_consent: image_consent)

      ActivityEnrollment.create(student: @student, activity: activity, confirmed: true)
      @student.courses << activity.next_courses

      start_year = annual_program.starts_at.year
      membership = @student.memberships.find_by(start_year: start_year)
      if membership.nil?
        @student.memberships.create(amount: Membership::PRICE, start_year: start_year, academy: academy)
      end
      flash.now[:notice] = "Inscription validée"
      @activity_enrollment = @student.activity_enrollments.find_by(activity: activity)
      @courses = activity.next_courses
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to managers_student_path(@student), notice: "Inscription réussie." }
      end
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
