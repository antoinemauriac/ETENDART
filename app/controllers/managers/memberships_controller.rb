class Managers::MembershipsController < ApplicationController

  def update
    @membership = Membership.find(params[:id])
    @student = @membership.student
    authorize([:managers, @membership])
    if @membership.update(membership_params)
      @membership.update(status: true, payment_date: Date.current)
      if params[:url]
        flash[:notice] = "Cotisation de #{@student.first_name} validée"
        redirect_to params[:url]
      else
        flash[:notice] = "Cotisation de #{@student.first_name} validée"
        redirect_to coaches_student_profile_path(@student)
      end
    else
      flash[:alert] = "Une erreur est survenue"
      redirect_to coaches_student_profile_path(@student)
    end
  end

  private

  def membership_params
    params.require(:membership).permit(:start_year, :amount, :payment_method, :status, :payment_date, :receiver_id)
  end
end
