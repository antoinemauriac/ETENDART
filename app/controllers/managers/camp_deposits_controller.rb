class Managers::CampDepositsController < ApplicationController
  def create
    camp_deposit = CampDeposit.new(camp_deposit_params)
    authorize([:managers, @camp_deposit], policy_class: Managers::CampDepositPolicy)
    camp_deposit.manager = current_user
    camp_deposit.date = Date.current
    camp = Camp.find(camp_deposit_params[:camp_id])

    if camp_deposit.save
      flash[:notice] = 'Dépôt enregistré'
    else
      flash[:alert] = 'Erreur lors de l\'enregistrement du dépôt'
    end
    redirect_to managers_finance_path(camp.school_period)
  end

  private

  def camp_deposit_params
    params.require(:camp_deposit).permit(:amount, :camp_id)
  end
end
