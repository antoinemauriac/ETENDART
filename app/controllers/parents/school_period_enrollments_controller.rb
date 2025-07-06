class Parents::SchoolPeriodEnrollmentsController < Parents::BaseController
  def new
    setup_school_period_enrollment_data_with_auto_selection
  end

  def create
    authorize([:parents, SchoolPeriodEnrollment])
    academy = Academy.find(params[:academy_id])
    school_period = SchoolPeriod.find(params[:school_period_id])
    student = Student.find(school_period_enrollment_params[:student_id])

    ActiveRecord::Base.transaction do
      student.school_periods << school_period unless student.school_periods.include?(school_period)
      student.academies << academy unless student.academies.include?(academy)
      school_period_enrollment = student.school_period_enrollments.find_by(school_period: school_period)
      camp_enrollments = []

      generate_enrollments(params, student, camp_enrollments)

      if school_period_enrollment&.save
        generate_cart_items(camp_enrollments)
        manage_membership(student, academy, camp_enrollments)
        if params[:another_child] == "Inscrire un autre enfant"
          redirect_to new_parents_academy_school_period_school_period_enrollment_path(academy, school_period), notice: "Inscription ajoutée au panier"
        else
          redirect_to commerce_cart_path
        end
      else
        redirect_to new_parents_academy_school_period_school_period_enrollment_path(academy, school_period), alert: "Erreur lors de l'inscription de votre enfant"
      end
    end
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => e
    redirect_to new_parents_academy_school_period_school_period_enrollment_path(academy, school_period), alert: "Erreur lors de l'inscription de votre enfant: #{e.message}"
  end

  def filter_camps
    setup_school_period_enrollment_data_without_auto_selection
    render :new
  end

  private

  def setup_school_period_enrollment_data_with_auto_selection
    @academy = Academy.find(params[:academy_id])
    @school_period = SchoolPeriod.find(params[:school_period_id])
    authorize([:parents, SchoolPeriodEnrollment])

    @school_period_enrollment = SchoolPeriodEnrollment.new
    @students = current_user.children
    if @students.empty?
      redirect_to parents_children_path
      return
    end

    # Sélectionner l'étudiant initial
    initial_student = params[:student_id].present? ? Student.find(params[:student_id]) : @students&.first

    # Vérifier si l'étudiant initial est déjà inscrit à tous les camps de cette période
    enrolled_camps = initial_student.camp_enrollments.where(camp: @school_period.camps)
    available_camps = @school_period.camps_with_activities
                      .where.not(id: enrolled_camps.pluck(:camp_id))
                      .not_full

    if available_camps.empty?
      # Chercher un autre étudiant qui a des camps disponibles
      available_student = @students.find do |student|
        student_enrolled_camps = student.camp_enrollments.where(camp: @school_period.camps)
        student_available_camps = @school_period.camps_with_activities
                                  .where.not(id: student_enrolled_camps.pluck(:camp_id))
                                  .not_full
        !student_available_camps.empty?
      end
      @selected_student = available_student || initial_student
    else
      @selected_student = initial_student
    end

    setup_common_camp_data
  end

  def setup_school_period_enrollment_data_without_auto_selection
    @academy = Academy.find(params[:academy_id])
    @school_period = SchoolPeriod.find(params[:school_period_id])
    authorize([:parents, SchoolPeriodEnrollment])

    @school_period_enrollment = SchoolPeriodEnrollment.new
    @students = current_user.children
    if @students.empty?
      redirect_to parents_children_path
      return
    end

    # Utiliser directement l'étudiant sélectionné sans auto-sélection
    @selected_student = params[:student_id].present? ? Student.find(params[:student_id]) : @students&.first

    setup_common_camp_data
  end

  def setup_common_camp_data
    enrolled_camps = @selected_student.camp_enrollments.where(camp: @school_period.camps)
    @camps = @school_period.camps_with_activities
                           .where.not(id: enrolled_camps.pluck(:camp_id))
                           .not_full
                           .order(:starts_at)
  end

  def school_period_enrollment_params
    params.require(:school_period_enrollment).permit(
      :school_period_id,
      :student_id,
      :camp_ids => [],
      :camp_id => {}
    )
  end

  def generate_enrollments(params, student, camp_enrollments)
    params[:camp_ids].each do |camp_id|
      camp = Camp.find(camp_id)
      camp_enrollment = CampEnrollment.create!(
        camp:,
        student:,
        image_consent: student.has_consent_for_photos || false,
        stripe_price_id: camp.stripe_price_id
      ) unless student.camp_enrollments.find_by(camp:)

      camp_enrollments << camp_enrollment if camp_enrollment

      activity_params = params[:camp_id][camp_id]
      next unless activity_params.present?

      sport_activity = Activity.find(activity_params[:sport_activity_id])
      eveil_activity = Activity.find(activity_params[:eveil_activity_id])
      student.activities << sport_activity unless student.activities.include?(sport_activity)
      student.activities << eveil_activity unless student.activities.include?(eveil_activity)
    end
  end

  def generate_cart_items(camp_enrollments)
    camp_enrollments.each do |camp_enrollment|
      Commerce::CartItem.create!(
        cart: current_user.pending_cart,
        student: camp_enrollment.student,
        product: camp_enrollment,
        price: camp_enrollment.camp.price,
        stripe_price_id: camp_enrollment.stripe_price_id,
        payment_method: camp_enrollment.camp.price == 0 ? "offert" : "Carte bancaire",
        name: "Inscription #{camp_enrollment.camp.academy.name} - #{camp_enrollment.school_period.name} - #{camp_enrollment.camp.name} - #{camp_enrollment.student.full_name}"
      )
    end
  end

  def manage_membership(student, academy, camp_enrollments)
    # Gérer chaque camp_enrollment individuellement car ils peuvent être de mois différents
    camp_enrollments.each do |camp_enrollment|
      camp = camp_enrollment.camp
      start_year = camp.starts_at.month >= 9 ? camp.starts_at.year : camp.starts_at.year - 1

      membership = student.memberships.find_by(start_year:)
      membership ||= Membership.create!(student:, start_year:, academy:, amount: Membership::PRICE, stripe_price_id: ENV["STRIPE_MEMBERSHIP_ID"])

      next if membership.paid

      # Vérifier si un membership pour cette année existe déjà dans le panier
      existing_membership_cart_items = Commerce::CartItem.where(cart: current_user.pending_cart, student:, product_type: "Membership")
      next if existing_membership_cart_items.any? { |item| item.product.start_year == start_year }

      Commerce::CartItem.create!(
        cart: current_user.pending_cart,
        student:,
        product: membership,
        price: Membership::PRICE,
        stripe_price_id: ENV["STRIPE_MEMBERSHIP_ID"],
        name: "Adhésion #{start_year}/#{start_year + 1} - #{student.first_name} #{student.last_name}"
      )
    end
  end
end
