class Managers::AnnualProgramEnrollmentsController < ApplicationController
  def destroy
    @annual_program_enrollment = AnnualProgramEnrollment.find(params[:id])
    authorize([:managers, @annual_program_enrollment])

    if @annual_program_enrollment.paid && @annual_program_enrollment.annual_program.price > 0
      @cannot_remove = true
      flash.now[:alert] = "Impossible de supprimer une inscription déjà payée"
    else
      student = @annual_program_enrollment.student
      annual_program = @annual_program_enrollment.annual_program

      if @annual_program_enrollment.destroy
        student.activity_enrollments.where(activity: annual_program.activities).destroy_all
        student.course_enrollments.where(course: annual_program.courses).destroy_all
        manage_membership(student, annual_program)
        flash.now[:notice] = "Élève retiré du programme"
      else
        flash.now[:alert] = "Erreur lors de la suppression"
      end
    end

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to managers_annual_program_path(@annual_program_enrollment.annual_program) }
    end
  end

  def update
    @annual_program_enrollment = AnnualProgramEnrollment.find(params[:id])
    authorize([:managers, @annual_program_enrollment])

    if @annual_program_enrollment.paid
      flash[:alert] = "Paiement déjà enregistré"
      handle_response
      return
    end

    @student = @annual_program_enrollment.student
    payment_method = params[:annual_program_enrollment][:payment_method]

    if @annual_program_enrollment.update(annual_program_enrollment_params)
      @annual_program_enrollment.update(paid: true, payment_date: Date.current)
      if !["cash", "cheque", "offert"].include?(payment_method)
        @annual_program_enrollment.update(receiver_id: nil)
      end
      flash[:notice] = "Paiement enregistré"
    else
      flash[:alert] = @annual_program_enrollment.errors.full_messages.to_sentence
    end

    handle_response
  end

  def handle_response
    respond_to do |format|
      format.turbo_stream do
        flash.discard
      end
      format.html do
        redirect_to "#{params[:annual_program_enrollment][:origin] || params[:origin] || managers_student_path(@student)}#target-#{@annual_program_enrollment.id}"
      end
    end
  end

  private

  def manage_membership(student, annual_program)
    start_year = annual_program.starts_at.month >= 9 ? annual_program.starts_at.year : annual_program.starts_at.year - 1
    courses_during_civil_year = student.courses.where('starts_at >= ? AND starts_at <= ?', Date.new(start_year, 4, 7), Date.new(start_year + 1, 8, 31))
    membership = student.memberships.find_by(start_year: start_year)
    if courses_during_civil_year.empty? && membership && membership.paid == false
      membership&.destroy
    end
  end

  def annual_program_enrollment_params
    params.require(:annual_program_enrollment).permit(:payment_method, :receiver_id)
  end
end
