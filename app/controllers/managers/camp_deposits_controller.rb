class Managers::CampDepositsController < ApplicationController

  def create
    camp_deposit = CampDeposit.new(camp_deposit_params)
    authorize([:managers, camp_deposit], policy_class: Managers::CampDepositPolicy)

    camp = Camp.find(params[:camp_deposit][:camp_id])
    depositor = User.find(params[:camp_deposit][:depositor_id])
    price = camp.price

    cash_deposit = depositor.camp_deposits_as_depositor.where(camp: camp).sum(:cash_amount)
    cash_received = camp.camp_enrollments.paid.where(payment_method: 'cash', receiver: depositor).count * price
    cash_to_deposit = cash_received - cash_deposit

    cheque_deposit = depositor.camp_deposits_as_depositor.where(camp: camp).sum(:cheque_amount)
    cheque_received = camp.camp_enrollments.paid.where(payment_method: 'cheque', receiver: depositor).count * price
    cheque_to_deposit = cheque_received - cheque_deposit

    if cash_to_deposit < params[:camp_deposit][:cash_amount].to_f || cheque_to_deposit < params[:camp_deposit][:cheque_amount].to_f
      flash[:alert] = "Erreur : le montant du dépôt est supérieur au montant qu'il reste à déposer popur ce coach"
      redirect_to show_camp_managers_finance_path(camp)
      return
    end
    camp_deposit.assign_attributes(camp: camp, manager: current_user, depositor: depositor, date: Date.current)

    if camp_deposit.save
      flash[:notice] = 'Dépôt enregistré'
      redirect_to show_camp_managers_finance_path(camp)
    else
      flash[:alert] = 'Erreur : au moins un montant doit être renseigné'
      redirect_to show_camp_managers_finance_path(camp)
    end
  end

  private

  def camp_deposit_params
    params.require(:camp_deposit).permit(:cash_amount, :cheque_amount)
  end
end
