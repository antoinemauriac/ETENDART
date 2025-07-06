class Parents::AnnualProgramEnrollmentsController < Parents::BaseController
  def new
    setup_annual_program_enrollment_data_with_auto_selection
  end

  def create
    authorize([:parents, AnnualProgramEnrollment])
    annual_program = AnnualProgram.find(params[:annual_program_id])
    academy = annual_program.academy
    student = Student.find(annual_program_enrollment_params[:student_id])

    ActiveRecord::Base.transaction do
      student.academies << academy unless student.academies.include?(academy)

      annual_program_enrollment = AnnualProgramEnrollment.new(
        annual_program:,
        student:,
        stripe_price_id: annual_program.stripe_price_id,
        image_consent: student.has_consent_for_photos || false
      ) unless student.annual_program_enrollments.find_by(annual_program:)

      # Ajouter les activités sélectionnées
      sport_activity = Activity.find(annual_program_enrollment_params[:sport_activity_id])
      eveil_activity = Activity.find(annual_program_enrollment_params[:eveil_activity_id])

      student.activities << sport_activity unless student.activities.include?(sport_activity)
      student.activities << eveil_activity unless student.activities.include?(eveil_activity)

      # Ajouter l'activité de soutien scolaire si sélectionnée
      if annual_program_enrollment_params[:soutien_activity_id].present?
        soutien_activity = Activity.find(annual_program_enrollment_params[:soutien_activity_id])
        student.activities << soutien_activity unless student.activities.include?(soutien_activity)
      end

      if annual_program_enrollment&.save
        generate_cart_item(student, annual_program_enrollment, annual_program)
        manage_membership(student, annual_program, academy)
        if params[:another_child] == "Inscrire un autre enfant"
          redirect_to parents_annual_program_annual_program_enrollments_path(annual_program), notice: "Inscription ajoutée au panier"
        else
          redirect_to commerce_cart_path
        end
      else
        redirect_to parents_annual_program_annual_program_enrollments_path(annual_program), alert: "Erreur lors de l'inscription de votre enfant" and return
      end
    end
  rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotFound => e
    redirect_to parents_annual_program_annual_program_enrollments_path(annual_program), alert: "Erreur lors de l'inscription de votre enfant: #{e.message}" and return
  end

  def filter_annual_programs
    setup_annual_program_enrollment_data_without_auto_selection
    render :new
  end

  private

  def setup_annual_program_enrollment_data_with_auto_selection
    @annual_program = AnnualProgram.find(params[:annual_program_id])
    @academy = @annual_program.academy
    authorize([:parents, AnnualProgramEnrollment])

    @annual_program_enrollment = AnnualProgramEnrollment.new
    @students = current_user.children
    if @students.empty?
      redirect_to parents_children_path
      return
    end

    # Sélectionner l'étudiant initial
    initial_student = params[:student_id].present? ? Student.find(params[:student_id]) : @students&.first

    # Vérifier si l'étudiant initial est déjà inscrit au programme annuel
    if initial_student.annual_program_enrollments.exists?(annual_program: @annual_program)
      # Chercher un autre étudiant non inscrit
      available_student = @students.find { |student| !student.annual_program_enrollments.exists?(annual_program: @annual_program) }
      @selected_student = available_student || initial_student
    else
      @selected_student = initial_student
    end

    setup_common_data
  end

  def setup_annual_program_enrollment_data_without_auto_selection
    @annual_program = AnnualProgram.find(params[:annual_program_id])
    @academy = @annual_program.academy
    authorize([:parents, AnnualProgramEnrollment])

    @annual_program_enrollment = AnnualProgramEnrollment.new
    @students = current_user.children
    if @students.empty?
      redirect_to parents_children_path
      return
    end

    # Utiliser directement l'étudiant sélectionné sans auto-sélection
    @selected_student = params[:student_id].present? ? Student.find(params[:student_id]) : @students&.first

    setup_common_data
  end

  def setup_common_data
    enrolled_activities = @selected_student.activity_enrollments.where(activity: @annual_program.activities)
    @activities = @annual_program.activities
                                 .where.not(id: enrolled_activities.pluck(:activity_id))
                                 .order(:name)
    enrolled_annual_programs = @selected_student.annual_program_enrollments.where(annual_program: @academy.annual_programs)
    @annual_programs = @academy.annual_programs
                               .not_full
                               .where.not(id: enrolled_annual_programs.pluck(:annual_program_id))
                               .where(ends_at: Date.current..Date.current + 1.year)
                               .order(:starts_at)
  end

  def annual_program_enrollment_params
    params.require(:annual_program_enrollment).permit(
      :annual_program_id,
      :student_id,
      :sport_activity_id,
      :eveil_activity_id,
      :soutien_activity_id
    )
  end

  def generate_cart_item(student, annual_program_enrollment, annual_program)
    cart_item = Commerce::CartItem.find_by(cart: current_user.pending_cart, student:, product_type: "AnnualProgramEnrollment")
    return if cart_item

    Commerce::CartItem.create!(
      cart: current_user.pending_cart,
      student:,
      product: annual_program_enrollment,
      price: annual_program.price,
      stripe_price_id: annual_program.stripe_price_id,
      payment_method: annual_program.price == 0 ? "offert" : "Carte bancaire",
      name: "Programme #{annual_program.academy.name} - #{annual_program.short_name} - #{student.full_name}"
    )
  end

  def manage_membership(student, annual_program, academy)
    start_year = annual_program.starts_at.year
    membership = student.memberships.find_by(start_year:)
    membership ||= Membership.create!(student:, start_year:, academy:, amount: Membership::PRICE, stripe_price_id: ENV["STRIPE_MEMBERSHIP_ID"])

    return if membership.paid

    existing_membership_cart_items = Commerce::CartItem.where(cart: current_user.pending_cart, student:, product_type: "Membership")
    return if existing_membership_cart_items.any? && existing_membership_cart_items.any? { |item| item.product.start_year == start_year }

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
