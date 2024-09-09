class Managers::MembershipDepositsController < ApplicationController

  def index
    @start_year = Date.current.month >= 9 ? Date.current.year : Date.current.year - 1
    academy_ids = current_user.academies.pluck(:id)
    user_ids = Membership.where(academy_id: academy_ids, start_year: @start_year, status: true).distinct.pluck(:receiver_id)
    @users = User.where(id: user_ids).order(:last_name)

    if params[:coach].present? && params[:coach] != "all"
      @membership_deposits = User.find(params[:coach]).membership_deposits_as_depositor.order(created_at: :desc)
    else
      @membership_deposits = MembershipDeposit.where(depositor_id: user_ids).order(created_at: :desc)
    end
    skip_policy_scope
    authorize([:managers, @membership_deposits], policy_class: Managers::MembershipDepositPolicy)
    respond_to do |format|
      format.html
      format.text { render partial: "managers/membership_deposits/membership_deposit_list", locals: {membership_deposits: @membership_deposits }, formats: [:html] }
    end
  end

  def create
    membership_deposit = MembershipDeposit.new(membership_deposit_params)
    authorize([:managers, membership_deposit], policy_class: Managers::MembershipDepositPolicy)
    membership_deposit.manager = current_user
    membership_deposit.depositor = User.find(params[:membership_deposit][:depositor_id])
    membership_deposit.date = Date.current
    start_year = Date.current.month >= 9 ? Date.current.year : Date.current.year - 1
    membership_deposit.start_year = start_year
    if membership_deposit.save
      flash[:notice] = 'Dépôt enregistré'
      redirect_to membership_finances_overview_managers_finances_path
    else
      flash[:alert] = 'Erreur : au moins un montant doit être renseigné'
      redirect_to membership_finances_overview_managers_finances_path
    end
  end

  private

  def membership_deposit_params
    params.require(:membership_deposit).permit(:cash_amount, :cheque_amount)
  end
end
