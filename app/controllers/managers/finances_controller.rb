class Managers::FinancesController < ApplicationController
  def membership_finances_overview
    skip_policy_scope
    authorize([:managers, :finance], policy_class: Managers::FinancePolicy)
    @academies = current_user.academies_as_manager
    academy_ids = @academies.pluck(:id)
    @start_year = Date.current.month >= 4 ? Date.current.year : Date.current.year - 1

    # Sélectionner tous les memberships pour les académies gérées
    @all_memberships = Membership.where(academy_id: academy_ids)

    # Calculs globaux
    @all_memberships_count = @all_memberships.count
    paid_memberships_excluding_offered = @all_memberships.paid.where.not(payment_method: 'offert')

    @total_expected_revenue = paid_memberships_excluding_offered.sum(:amount)

    @all_paid_memberships_count = paid_memberships_excluding_offered.count
    @total_received_revenue = paid_memberships_excluding_offered.sum(:amount)

    @all_unpaid_memberships_count = @all_memberships.unpaid.count
    @total_missing_revenue = @all_memberships.unpaid.sum(:amount)

    # Calculs pour l'année courante
    @current_year_memberships = @all_memberships.where(start_year: @start_year)
    @current_year_memberships_count = @current_year_memberships.count
    @current_year_expected_revenue = @current_year_memberships.sum(:amount)

    @current_year_offered_memberships_count = @current_year_memberships.where(payment_method: 'offert').count
    @current_year_offered_revenue = @current_year_memberships.where(payment_method: 'offert').sum(:amount)

    current_year_paid_memberships_excluding_offered = @current_year_memberships.paid.where.not(payment_method: 'offert')
    @current_year_paid_memberships_count = current_year_paid_memberships_excluding_offered.count
    @current_year_received_revenue = current_year_paid_memberships_excluding_offered.sum(:amount)

    @current_year_unpaid_memberships_count = @current_year_memberships.unpaid.count
    @current_year_missing_revenue = @current_year_memberships.unpaid.sum(:amount)

    # Revenu total par utilisateur (hors offerts)
    revenue_by_user = paid_memberships_excluding_offered.group(:receiver_id).sum(:amount)
    @revenue_by_user = revenue_by_user.sort_by { |_, total_received| -total_received }.to_h

    # Répartition par moyen de paiement
    @payment_details_by_user = @current_year_memberships.paid.group(:receiver_id, :payment_method).order(:receiver_id).sum(:amount)
  end

  def camp_finances_overview
    skip_policy_scope
    authorize([:managers, :finance], policy_class: Managers::FinancePolicy)
    @academies = current_user.academies_as_manager
    academy_ids = @academies.pluck(:id)

    # selectionner les camp appartenant à une school_period qui a un attribut paid à true et qui appartient à l'une des académie

    @school_periods = SchoolPeriod.where(paid: true, academy_id: academy_ids)
    @camps = Camp.where(school_period_id: @school_periods.pluck(:id))
  end
end
