class Parents::SchoolPeriodEnrollmentsController < ApplicationController
  def new
    authorize([:parents, SchoolPeriodEnrollment])
    @academy = Academy.find(params[:academy_id])
    @school_period = SchoolPeriod.find(params[:school_period_id])

    @school_period_enrollment = SchoolPeriodEnrollment.new
    @students = current_user.children
    if @students.empty?
      redirect_to parents_children_path, alert: "Vous devez ajouter un enfant avant de pouvoir inscrire un enfant à un stage"
      return
    end
    @selected_student = params[:student_id].present? ? Student.find(params[:student_id]) : @students&.first
    # retrouver les camps ou le selected_student n'est pas encore inscrit
    enrolled_camp_ids = @selected_student
                     .camp_enrollments
                     .joins(:school_period_enrollment)
                     .where(school_period_enrollments: { school_period_id: @school_period.id })
                     .pluck(:camp_id)

    @camps = @school_period.camps.where.not(id: enrolled_camp_ids)
  end

  def create
    authorize([:parents, SchoolPeriodEnrollment])
    # Il se peut qu'il y ait déjà un enrollment pour ce school_period et ce student
    # Il faut donc vérifier si un enrollment existe déjà pour ce student et ce school_period
    # il faut le retrouver ou l'initialiser
    @academy = Academy.find(params[:academy_id])
    @school_period = SchoolPeriod.find(params[:school_period_id])
    @school_period_enrollment = SchoolPeriodEnrollment.find_or_initialize_by(
      school_period_id: @school_period.id,
      student_id: school_period_enrollment_params[:student_id]
      )

      # j'initialise camp_enrollments grâce à params[:camp_ids]
      params[:camp_ids].each do |camp_id|
        camp = Camp.find(camp_id)
        camp_enrollment = @school_period_enrollment.camp_enrollments.build(camp: camp)
        camp_enrollment.student = Student.find(school_period_enrollment_params[:student_id])
        camp_enrollment.image_consent = camp_enrollment.student.photo_authorization || false
        camp_enrollment.stripe_price_id = camp.stripe_price_id

        # faire correspondre les activities avec les activités choisies et le bon camp
        activity_params = params[:camp_id][camp_id]
        next unless activity_params.present?
        sport_activity_id  = activity_params[:sport_activity_id]
        eveil_activity_id  = activity_params[:eveil_activity_id]
        camp_enrollment.activity_enrollments.build(activity_id: sport_activity_id, student_id: camp_enrollment.student.id)
        camp_enrollment.activity_enrollments.build(activity_id: eveil_activity_id, student_id: camp_enrollment.student.id)
      end

    if @school_period_enrollment.save

      @school_period_enrollment.camp_enrollments.each do |camp_enrollment|
        cart_item = Commerce::CartItem.create!(
          cart_id: current_user.pending_cart.id,
          student_id: camp_enrollment.student.id,
          product: camp_enrollment,
          price: camp_enrollment.school_period.price,
          stripe_price_id: camp_enrollment.stripe_price_id,
          name: "Inscription #{camp_enrollment.school_period.name}/#{camp_enrollment.camp.name}/#{camp_enrollment.camp.academy.name} - #{camp_enrollment.student.first_name} #{camp_enrollment.student.last_name}"
        )
      end

      if params[:another_child] == "Inscrire un autre enfant"
        redirect_to new_parents_academy_school_period_school_period_enrollment_path(@academy, @school_period), notice: "L'inscription de votre enfant a bien été pré-enregistrée, veuillez inscrire un autre enfant"
      else
        redirect_to commerce_cart_path, notice: "L'inscription de votre enfant a bien été pré-enregistrée"
      end
    else
      redirect_to new_parents_academy_school_period_school_period_enrollment_path, alert: "Erreur lors de l'inscription de votre enfant"
    end
  end

  def filter_camps
    authorize([:parents, SchoolPeriodEnrollment])
    @academy = Academy.find(params[:academy_id])
    @school_period = SchoolPeriod.find(params[:school_period_id])
    @school_period_enrollment = SchoolPeriodEnrollment.new
    @selected_student = Student.find(params[:student_id])
    @students = current_user.children
    # @camps représente les camps ou le selected_student n'est pas encore inscrit
    enrolled_camp_ids = @selected_student
                     .camp_enrollments
                     .joins(:school_period_enrollment)
                     .where(school_period_enrollments: { school_period_id: @school_period.id })
                     .pluck(:camp_id)

    @camps = @school_period.camps.where.not(id: enrolled_camp_ids)
    render :new
  end

  private

  def school_period_enrollment_params
    params.require(:school_period_enrollment).permit(
      :school_period_id,
      :student_id,
      :camp_ids => [],
      :camp_id => {}
    )
  end

end
