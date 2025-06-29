class Managers::EnrollmentsController < ApplicationController

  def create
    @student = Student.find(params[:student_id])
    authorize([:managers, @student], policy_class: Managers::EnrollmentPolicy)
    activity = Activity.find(params[:activity])

    if @student.confirmed_activity_enrollments.exists?(activity: activity)
      flash.now[:alert] = "L'élève est déjà inscrit à cette activité"

      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("flash-messages", partial: "shared/flashes") }
        format.html { redirect_to managers_student_path(student), alert: flash[:alert] }
      end
    else
      academy = Academy.find(params[:academy])
      @student.academies << academy unless @student.academies.include?(academy)

      school_period = SchoolPeriod.find(params[:school_period])
      @student.school_periods << school_period unless @student.school_periods.include?(school_period)

      # je vérifie si une distribution de tshirt est prévue pour la school_period
      if school_period.tshirt == true
        # je recherche les school_period_enrollments de l'élève pour l'academy concernée
        school_period_enrollments = @student.school_period_enrollments
                                            .joins(:school_period)
                                            .where(school_periods: { academy_id: academy.id })
        # je récupère le school_period_enrollment de la school_period en cours
        school_period_enrollment = @student.school_period_enrollments.find_by(school_period: school_period)
        # je vérifie si l'élève a déjà reçu un tshirt pour une des school_period de l'academy
        if school_period_enrollments.any? { |school_period_enrollment| school_period_enrollment.tshirt_delivered == true }
          school_period_enrollment.update(tshirt_delivered: true)
        end
      end

      # inscription au camp
      camp = Camp.find(params[:camp])
      image_consent = params[:has_consent_for_photos]
      CampEnrollment.create!(student: @student, camp: camp, confirmed: true, image_consent: image_consent) unless @student.confirmed_camp_enrollments.exists?(camp: camp)

      # inscription à l'activité
      ActivityEnrollment.create(student: @student, activity: activity, confirmed: true)

      # inscription aux cours de l'activité
      @student.courses << activity.next_courses

      # gestion de la membership
      start_year = camp.starts_at.month >= 9 ? camp.starts_at.year : camp.starts_at.year - 1
      membership = @student.memberships.find_by(start_year: start_year)
      if membership.nil?
        @student.memberships.create(amount: Membership::PRICE, start_year: start_year, academy: academy)
      end
      flash.now[:notice] = "Inscription validée"
      @activity_enrollment = @student.activity_enrollments.find_by(activity: activity)
      @courses = activity.next_courses
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to managers_student_path(@student), notice: "Inscription réussie." }
      end
    end
  end

  def update_school_periods
    academy = Academy.find(params[:academy_id])
    authorize([:managers, academy], policy_class: Managers::EnrollmentPolicy)
    school_periods = academy.school_periods.select(:id, :name, :year).select { |school_period| school_period.ends_at >= Date.today }
    render json: school_periods.as_json(methods: :full_name)
  end

  def update_camps
    school_period = SchoolPeriod.find(params[:school_period_id])
    authorize([:managers, school_period], policy_class: Managers::EnrollmentPolicy)
    camps = school_period.camps
    render json: camps.select(:id, :name).where('ends_at >= ?', Date.today).order(:starts_at)
  end

  def update_activities
    camp = Camp.find(params[:camp_id])
    authorize([:managers, camp], policy_class: Managers::EnrollmentPolicy)
    activities = camp.activities
    render json: activities.select(:id, :name).order(:name)
  end

end
