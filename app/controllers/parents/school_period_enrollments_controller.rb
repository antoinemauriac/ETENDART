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
    enrolled_camps = @selected_student.camp_enrollments.where(camp: @school_period.camps)
    @camps = @school_period.camps.where.not(id: enrolled_camps.pluck(:camp_id))
  end

  def create
    authorize([:parents, SchoolPeriodEnrollment])
    academy = Academy.find(params[:academy_id])
    school_period = SchoolPeriod.find(params[:school_period_id])
    student = Student.find(school_period_enrollment_params[:student_id])
    student.school_periods << school_period unless student.school_periods.include?(school_period)
    student.academies << academy unless student.academies.include?(academy)
    school_period_enrollment = student.school_period_enrollments.find_by(school_period: school_period)
    camp_enrollments = []

    params[:camp_ids].each do |camp_id|
      camp = Camp.find(camp_id)
      camp_enrollment = CampEnrollment.create!(
        camp: camp,
        student: student,
        image_consent: student.photo_authorization || false,
        stripe_price_id: camp.stripe_price_id
      ) unless student.camp_enrollments.find_by(camp: camp)

      camp_enrollments << camp_enrollment

      activity_params = params[:camp_id][camp_id]
      next unless activity_params.present?
      sport_activity = Activity.find(activity_params[:sport_activity_id])
      eveil_activity = Activity.find(activity_params[:eveil_activity_id])
      student.activities << sport_activity unless student.activities.include?(sport_activity)
      student.activities << eveil_activity unless student.activities.include?(eveil_activity)
    end

    if school_period_enrollment.save
      camp_enrollments.each do |camp_enrollment|
        Commerce::CartItem.create!(
          cart_id: current_user.pending_cart.id,
          student_id: camp_enrollment.student.id,
          product: camp_enrollment,
          price: camp_enrollment.school_period.price,
          stripe_price_id: camp_enrollment.stripe_price_id,
          name: "Inscription #{camp_enrollment.school_period.name}/#{camp_enrollment.camp.name}/#{camp_enrollment.camp.academy.name} - #{camp_enrollment.student.first_name} #{camp_enrollment.student.last_name}"
        )
      end

      start_year = Date.current.month >= 9 ? Date.current.year : Date.current.year - 1
      membership = student.memberships.find_by(start_year: start_year)
      unless membership
        membership = Membership.create!(
          student: student,
          start_year: start_year,
          academy: academy,
          amount: Membership::PRICE,
          stripe_price_id: "price_1Qge21AIwJB98t7nzUx7mFiH"
        )
      end

      unless membership.paid
        existing_cart_item = Commerce::CartItem.find_by(
          cart_id: current_user.pending_cart.id,
          student_id: student.id,
          product_type: "Membership"
        )

        unless existing_cart_item
          Commerce::CartItem.create!(
            cart_id: current_user.pending_cart.id,
            student_id: student.id,
            product: membership,
            price: Membership::PRICE,
            stripe_price_id: "price_1Qge21AIwJB98t7nzUx7mFiH",
            name: "Adhésion #{start_year} - #{student.first_name} #{student.last_name}"
          )
        end
      end

      if params[:another_child] == "Inscrire un autre enfant"
        redirect_to new_parents_academy_school_period_school_period_enrollment_path(academy, school_period), notice: "Inscription ajoutée au panier"
      else
        redirect_to commerce_cart_path, notice: "Inscription ajoutée au panier"
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

    enrolled_camps = @selected_student.camp_enrollments.where(camp: @school_period.camps)
    @camps = @school_period.camps.where.not(id: enrolled_camps.pluck(:camp_id))
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
