class Managers::FinancesController < ApplicationController
  def membership_finances_overview
    skip_policy_scope
    authorize([:managers, :finance], policy_class: Managers::FinancePolicy)
    @academies = current_user.academies
    academy_ids = @academies.pluck(:id)
    @start_year = Date.current.month >= 9 ? Date.current.year : Date.current.year - 1

    # Sélectionner tous les memberships pour les académies gérées
    @all_memberships = Membership.where(academy_id: academy_ids)

    # cotisations des élèves ayant particpé à au mons un cours
    @all_expected_memberships = Membership.where(academy_id: academy_ids)
                                          .where(student_id: Student.with_at_least_one_course(@start_year))


    # cotisation des élèves qui n'ont particpé à aucun cours et donc cotisation non exigible
    @all_not_expected_memberships = Membership.where(academy_id: academy_ids)
                                              .where.not(student_id: Student.with_at_least_one_course(@start_year))

    # paid_memberships_excluding_offered =
    # @total_expected_revenue = paid_memberships_excluding_offered.sum(:amount)

    # @all_paid_memberships_count = paid_memberships_excluding_offered.count
    # @total_received_revenue = paid_memberships_excluding_offered.sum(:amount)

    # @all_unpaid_memberships_count = @all_memberships.unpaid.count
    # @total_missing_revenue = @all_memberships.unpaid.sum(:amount)


    # CALCULS POUR L'ANNÉE COURANTE

    # payés mais non exigibles (élèves ayant payé mais n'ayant particpé à aucun cours)

    @current_year_not_expected_memberships = @all_not_expected_memberships.paid.where(start_year: @start_year)
    @current_year_not_expected_memberships_count = @current_year_not_expected_memberships.paid.where.not(payment_method: 'offert').count
    @current_year_not_expected_revenue = @current_year_not_expected_memberships.paid.where.not(payment_method: 'offert').sum(:amount)

    # exigibles
    @current_year_expected_memberships = @all_expected_memberships.where(start_year: @start_year)

    # exigibles + payés mais non exigibles
    @current_year_memberships_count = @current_year_expected_memberships.where("payment_method IS NULL OR payment_method != ?", 'offert').count +
                                      @current_year_not_expected_memberships_count

    @current_year_revenue = @current_year_expected_memberships
                                    .where("payment_method IS NULL OR payment_method != ?", 'offert')
                                    .sum(:amount) + @current_year_not_expected_revenue


    @current_year_memberships = @all_memberships.where(start_year: @start_year)


    @current_year_offered_memberships_count = @current_year_expected_memberships.where(payment_method: 'offert').count +
                                              @current_year_not_expected_memberships.where(payment_method: 'offert').count
    @current_year_offered_revenue = @current_year_expected_memberships.where(payment_method: 'offert').sum(:amount) +
                                    @current_year_not_expected_memberships.where(payment_method: 'offert').sum(:amount)

    current_year_paid_memberships_excluding_offered = @current_year_expected_memberships.paid.where.not(payment_method: 'offert')
    @current_year_paid_memberships_count = current_year_paid_memberships_excluding_offered.count + @current_year_not_expected_memberships_count
    @current_year_received_revenue = current_year_paid_memberships_excluding_offered.sum(:amount) + @current_year_not_expected_revenue

    @current_year_unpaid_memberships_count = @current_year_expected_memberships.unpaid.count
    @current_year_missing_revenue = @current_year_expected_memberships.unpaid.sum(:amount)

    # Revenu total par utilisateur (hors offerts)
    revenue_by_user = @all_memberships.paid.where.not(payment_method: 'offert').where(start_year: @start_year).group(:receiver_id).sum(:amount)
    @revenue_by_user = revenue_by_user.sort_by { |_, total_received| -total_received }.to_h

    # Répartition par moyen de paiement
    @payment_details_by_user = @current_year_memberships.paid.group(:receiver_id, :payment_method).order(:receiver_id).sum(:amount)

    @users = User.where(id: revenue_by_user.keys).order(:last_name)

    @last_membership_deposits = MembershipDeposit.where(depositor_id: @users.ids).order(created_at: :desc).limit(3)

    @current_year_deposited_revenue =
      MembershipDeposit.where(depositor_id: @users.ids, start_year: @start_year).sum(:cash_amount) +
      MembershipDeposit.where(depositor_id: @users.ids, start_year: @start_year).sum(:cheque_amount) +
      current_year_paid_memberships_excluding_offered.where.not(payment_method: ["cash", "cheque"]).sum(:amount) +
      @current_year_not_expected_memberships.where.not(payment_method: ["cash", "cheque"]).sum(:amount)

    if params[:coach].present? && params[:coach] != "all"
      @current_year_paid_memberships = User.find(params[:coach]).memberships.where(start_year: @start_year).paid
    else
      @current_year_paid_memberships = @current_year_memberships.paid
    end
    respond_to do |format|
      format.html
      format.text { render partial: "managers/finances/members_list", locals: {current_year_memberships: @current_year_paid_memberships }, formats: [:html] }
    end
  end

  def index
    skip_policy_scope
    authorize([:managers, :finance], policy_class: Managers::FinancePolicy)
    # récupérer les académies gérées par l'utilisateur qui ont des school_periods avec une colonne paid à true
    @academies = current_user.academies.joins(:school_periods).where(school_periods: { paid: true, new: true }).distinct
  end

  def show
    skip_policy_scope
    authorize([:managers, :finance], policy_class: Managers::FinancePolicy)
    @school_period = SchoolPeriod.find(params[:id])
  end

  def export_members_csv
    skip_policy_scope
    authorize([:managers, :finance], policy_class: Managers::FinancePolicy)
    membership_ids = params[:membership_ids] || []
    memberships = Membership.where(id: membership_ids)
    start_year = Date.current.month >= 9 ? Date.current.year : Date.current.year - 1

    respond_to do |format|
      format.csv do
        csv_data = CSV.generate(col_sep: ';', encoding: 'UTF-8') do |csv|
          csv << ["Nom", "Prénom", "Genre", "Date de naissance", "Email", "Téléphone", "Adresse", "Code postal", "Ville", "Moyen de paiement", "Date paiement", "Personne ayant reçu le paiement", "Dernier cours", "Academie du derniers cours", "Sport Principal"]
          memberships.joins(:student).order("students.last_name ASC").each do |membership|
            student = membership.student
            csv << [
              student.last_name,
              student.first_name,
              student.gender,
              student.date_of_birth,
              student.email,
              student.phone_number,
              student.address,
              student.zipcode,
              student.city,
              membership.payment_method,
              membership.payment_date ? l(membership.payment_date, format: :date) : '',
              membership.receiver.full_name,
              student.last_attended_course_date ? l(student.last_attended_course_date, format: :date) : '',
              membership.academy&.name,
              student.predominant_sport
            ]
          end
        end
        send_data(csv_data, filename: "membres_#{start_year}_#{start_year + 1}.csv")
      end
    end
  end
end
