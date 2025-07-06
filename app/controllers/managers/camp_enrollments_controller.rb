class Managers::CampEnrollmentsController < ApplicationController
  def destroy
    @camp_enrollment = CampEnrollment.find(params[:id])
    authorize([:managers, @camp_enrollment])

    if @camp_enrollment.paid && @camp_enrollment.camp.price > 0
      @cannot_remove = true
      flash.now[:alert] = "Impossible de supprimer une inscription déjà payée"
    else
      student = @camp_enrollment.student
      camp = @camp_enrollment.camp

      if @camp_enrollment.destroy
        manage_membership(student, camp)
        flash.now[:notice] = "Élève retiré de la semaine"
      else
        flash.now[:alert] = "Erreur lors de la suppression"
      end
    end

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to managers_camp_path(@camp_enrollment.camp) }
    end
  end

  def index
    @camp = Camp.find(params[:camp_id])
    @camp_enrollments = @camp.camp_enrollments.confirmed
                            .includes(:student, :camp, :receiver)
                            .order('students.last_name ASC')
    @all_students_with_free_judo = @camp.all_students_with_free_judo
    skip_policy_scope
    authorize([:managers, @camp_enrollments])
  end

  def update
    @camp_enrollment = CampEnrollment.find(params[:id])
    authorize([:managers, @camp_enrollment])
    if @camp_enrollment.paid
      flash[:alert] = "Paiement déjà enregistré"
      handle_response
      return
    end
    @student = @camp_enrollment.student
    payment_method = params[:camp_enrollment][:payment_method]
    if @camp_enrollment.update(camp_enrollment_params)
      @camp_enrollment.update(paid: true, payment_date: Date.current)
      if !["cash", "cheque", "offert"].include?(payment_method)
        @camp_enrollment.update(receiver_id: nil)
      end
      flash[:notice] = "Paiement enregistré"
    else
      flash[:alert] = @camp_enrollment.errors.full_messages.to_sentence
    end
    handle_response
  end

  def handle_response
    respond_to do |format|
      format.turbo_stream do
        flash.discard
      end
      format.html do
        redirect_to "#{params[:camp_enrollment][:origin] || params[:origin] || managers_student_path(@student)}#target-#{@camp_enrollment.id}"
      end
    end
  end

  private

  def manage_membership(student, camp)
    start_year = camp.starts_at.month >= 9 ? camp.starts_at.year : camp.starts_at.year - 1
    courses_during_civil_year = student.courses.where('starts_at >= ? AND starts_at <= ?', Date.new(start_year, 4, 7), Date.new(start_year + 1, 8, 31))
    membership = student.memberships.find_by(start_year: start_year)
    if courses_during_civil_year.empty? && membership && membership.paid == false
      membership&.destroy
    end
  end

  def camp_enrollment_params
    params.require(:camp_enrollment).permit(:payment_method, :receiver_id)
  end
end
