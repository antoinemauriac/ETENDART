class Managers::FinancesController < ApplicationController
  def membership_finances_overview
    skip_policy_scope
    authorize([:managers, :finance], policy_class: Managers::FinancePolicy)
    @academies = current_user.academies_as_manager
    academy_ids = @academies.pluck(:id)
    @start_year = Date.current.month >= 4 ? Date.current.year : Date.current.year - 1

    # Sélectionner tous les memberships pour les académies gérées
    @all_memberships = Membership.where(academy_id: academy_ids)

    # cotisations des élèves ayant particpé à au mons un cours
    @all_expected_memberships = Membership.where(academy_id: academy_ids)
                                          .where(student_id: Student.with_at_least_one_course(@start_year))


    # cotisation des élèves qui n'ont particpé à aucun cours et donc cotisation non exigible
    @all_not_expected_memberships = Membership.where(academy_id: academy_ids)
                                              .where.not(student_id: Student.with_at_least_one_course(@start_year))
    # Calculs globaux
    @all_memberships_count = @all_memberships.count

    paid_memberships_excluding_offered = @all_memberships.paid.where.not(payment_method: 'offert')
    @total_expected_revenue = paid_memberships_excluding_offered.sum(:amount)

    @all_paid_memberships_count = paid_memberships_excluding_offered.count
    @total_received_revenue = paid_memberships_excluding_offered.sum(:amount)

    @all_unpaid_memberships_count = @all_memberships.unpaid.count
    @total_missing_revenue = @all_memberships.unpaid.sum(:amount)

    # Calculs pour l'année courante
    @current_year_expected_memberships = @all_expected_memberships.where(start_year: @start_year)
    @current_year_expected_memberships_count = @current_year_expected_memberships.count
    @current_year_expected_revenue = @current_year_expected_memberships
                                    .where("payment_method IS NULL OR payment_method != ?", 'offert')
                                    .sum(:amount)

    @current_year_not_expected_memberships = @all_not_expected_memberships.paid.where(start_year: @start_year)
    @current_year_not_expected_memberships_count = @current_year_not_expected_memberships.count
    @current_year_not_expected_revenue = @current_year_not_expected_memberships.sum(:amount)

    @current_year_memberships = @all_memberships.where(start_year: @start_year)

    @current_year_offered_memberships_count = @current_year_expected_memberships.where(payment_method: 'offert').count
    @current_year_offered_revenue = @current_year_expected_memberships.where(payment_method: 'offert').sum(:amount)

    current_year_paid_memberships_excluding_offered = @current_year_expected_memberships.paid.where.not(payment_method: 'offert')
    @current_year_paid_memberships_count = current_year_paid_memberships_excluding_offered.count
    @current_year_received_revenue = current_year_paid_memberships_excluding_offered.sum(:amount)

    @current_year_unpaid_memberships_count = @current_year_expected_memberships.unpaid.count
    @current_year_missing_revenue = @current_year_expected_memberships.unpaid.sum(:amount)

    # Revenu total par utilisateur (hors offerts)
    revenue_by_user = paid_memberships_excluding_offered.group(:receiver_id).sum(:amount)
    @revenue_by_user = revenue_by_user.sort_by { |_, total_received| -total_received }.to_h

    # Répartition par moyen de paiement
    @payment_details_by_user = @current_year_memberships.paid.group(:receiver_id, :payment_method).order(:receiver_id).sum(:amount)
  end

  def camp_finances_overview
    skip_policy_scope
    authorize([:managers, :finance], policy_class: Managers::FinancePolicy)

    @school_periods = SchoolPeriod.includes(:academy).where(paid: true)

    @academies = current_user.academies_as_manager
                  .joins(:school_periods)
                  .where(school_periods: { id: @school_periods.select(:id) })
                  .distinct

    @camps = Camp.where(school_period_id: @school_periods.pluck(:id))
  end

  def export_members_csv
    skip_policy_scope
    authorize([:managers, :finance], policy_class: Managers::FinancePolicy)
    membership_ids = params[:membership_ids] || []
    memberships = Membership.where(id: membership_ids)
    start_year = Date.current.month >= 4 ? Date.current.year : Date.current.year - 1

    respond_to do |format|
      format.csv do
        csv_data = CSV.generate(col_sep: ';', encoding: 'UTF-8') do |csv|
          csv << ["Nom", "Prénom", "Genre", "Date de naissance", "Email", "Téléphone", "Adresse", "Code postal", "Ville", "Moyen de paiement", "Academie Principale"]
          memberships.joins(:student).order("students.last_name ASC").each do |membership|
            student = membership.student
            csv << [student.last_name, student.first_name, student.gender, student.date_of_birth, student.email, student.phone_number, student.address, student.zipcode, student.city, membership.payment_method, membership.academy&.name]
          end
        end
        send_data(csv_data, filename: "membres_#{start_year}_#{start_year + 1}.csv")
      end
    end

  end

end
