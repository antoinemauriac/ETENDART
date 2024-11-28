class Managers::MembershipsController < ApplicationController

  def update
    @membership = Membership.find(params[:id])
    @student = @membership.student
    authorize([:managers, @membership])
    payment_method = params[:membership][:payment_method]

    if @membership.update(membership_params)
      update_membership(payment_method)
      flash[:notice] = "Cotisation de #{@student.first_name} validée"
    else
      flash[:alert] = "Une erreur est survenue"
    end
    flash.discard
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to coaches_student_profile_path(@student) }
    end
  end

  def create
    @student = Student.find(params[:membership][:student_id])
    @membership = Membership.new(membership_params)
    @membership.student = @student
    authorize([:managers, @membership])
    if @membership.save
      update_membership(@membership.payment_method)
      flash[:notice] = "Cotisation validée"
      redirect_to managers_student_path(@student)
    else
      flash[:alert] = "Une erreur est survenue"
      redirect_to managers_student_path(@student)
    end
  end

  private

  def membership_params
    params.require(:membership).permit(:start_year, :amount, :payment_method, :paid, :payment_date)
  end

  def update_membership(payment_method)
    @membership.update(paid: true, payment_date: Date.current, academy: @student.membership_academy)
    if ["cash", "cheque", "offert"].include?(payment_method)
      @membership.update(receiver_id: params[:membership][:receiver_id])
    end
  end
end
