class Managers::OldCampDepositsController < ApplicationController
  def create
    old_camp_deposit = OldCampDeposit.new(old_camp_deposit_params)
    authorize([:managers, @old_camp_deposit], policy_class: Managers::OldCampDepositPolicy)
    old_camp_deposit.manager = current_user
    old_camp_deposit.date = Date.current
    camp = Camp.find(old_camp_deposit_params[:camp_id])

    if old_camp_deposit.save
      flash[:notice] = 'Dépôt enregistré'
    else
      flash[:alert] = 'Le montant du dépôt doit être renseigné'
    end
    redirect_to show_school_period_managers_finance_path(camp.school_period)
  end

  private

  def old_camp_deposit_params
    params.require(:old_camp_deposit).permit(:amount, :camp_id)
  end
end
