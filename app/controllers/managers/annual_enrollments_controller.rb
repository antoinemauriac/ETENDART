class Managers::AnnualEnrollmentsController < ApplicationController
  def create
    @student = Student.find(params[:student_id])
    authorize([:managers, @student], policy_class: Managers::AnnualEnrollmentPolicy)
    activity = Activity.find(params[:activity])
    if @student.confirmed_activity_enrollments.exists?(activity: activity)
      flash.now[:alert] = "L'élève est déjà inscrit à cette activité"

      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("flash-messages", partial: "shared/flashes") }
        format.html { redirect_to managers_student_path(@student), alert: flash[:alert] }
      end
    else
      academy = activity.academy
      @student.academies << academy unless @student.academies.include?(academy)

      annual_program = AnnualProgram.find(params[:annual_program])
      image_consent = params[:has_consent_for_photos]
      unless @student.confirmed_annual_program_enrollments.exists?(annual_program:)
        AnnualProgramEnrollment.create(student: @student, annual_program:, confirmed: true, image_consent:)
      end

      ActivityEnrollment.create(student: @student, activity:, confirmed: true)
      @student.courses << activity.next_courses

      start_year = annual_program.starts_at.year
      membership = @student.memberships.find_by(start_year:)
      if membership.nil?
        @student.memberships.create(amount: Membership::PRICE, start_year:, academy:)
      end
      flash.now[:notice] = "Inscription validée"
      @activity_enrollment = @student.activity_enrollments.find_by(activity:)
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
