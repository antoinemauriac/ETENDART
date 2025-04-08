class Managers::CampsController < ApplicationController

  # before_action :set_cache_headers, only: [:show]

  def show
    @camp = Camp.find(params[:id])
    authorize([:managers, @camp])
    @school_period = @camp.school_period
    @academy = @school_period.academy
    @activities = @camp.activities
  end

  def activities
    @camp = Camp.find(params[:id])
    authorize([:managers, @camp])
    @activities = @camp.activities
    render partial: "managers/camps/activities", locals: { activities: @activities, camp: @camp }
  end

  def students
    @camp = Camp.find(params[:id])
    authorize([:managers, @camp])
    # @start_year = @camp.starts_at.month >= 9 ? @camp.starts_at.year : @camp.starts_at.year - 1
    @students = @camp.confirmed_students.includes(:memberships, :camp_enrollments, :school_period_enrollments, :activity_enrollments).order(:last_name)
    @camp_enrollments = @camp.camp_enrollments.includes(:student)
    @academy = @camp.academy
    @school_period = @camp.school_period
    render partial: "managers/camps/students", locals: { students: @students, camp: @camp, academy: @academy, school_period: @school_period, camp_enrollments: @camp_enrollments }
  end

  def create
    camp = Camp.new(camp_params)
    camp.school_period = SchoolPeriod.find(params[:school_period])
    authorize([:managers, camp])
    if camp.valid?
      # creer un produit stripe au nom du camp et de la periode scolaire et de l'academie
      product = Stripe::Product.create(name: "#{camp.name} - #{camp.school_period.name} - #{camp.school_period.year} - #{camp.school_period.academy.name}")
      price = Stripe::Price.create(product: product.id, unit_amount: camp.school_period.price * 100, currency: 'eur')
      camp.stripe_price_id = price.id
    end
    if camp.save
      # créer un nouveau product stripe pour le camp
      camp.camp_stat = CampStat.create(camp: camp)
      flash[:notice] = "Semaine créée avec succès"
    else
      flash[:alert] = "Erreur : " + camp.errors.full_messages.join(", ")
    end

    redirect_to managers_school_period_path(camp.school_period)
  end

  def destroy
    camp = Camp.find(params[:id])
    authorize([:managers, camp])
    school_period_enrollments = SchoolPeriodEnrollment.where(school_period: camp.school_period)
    school_period_enrollments.each do |school_period_enrollment|
      camps = school_period_enrollment.student.camps.where(school_period: camp.school_period)
      school_period_enrollment.destroy if camps == [camp]
    end
    camp.destroy
    redirect_to managers_school_period_path(camp.school_period)
    flash[:notice] = "Semaine supprimée"
  end

  def export_students_csv
    camp = Camp.find(params[:id])
    academy = camp.academy
    school_period = camp.school_period
    authorize([:managers, camp])
    students = camp.students.joins(:camp_enrollments).where(camp_enrollments: { confirmed: true }).distinct.sort_by(&:last_name)

    column_headers = ["Nom", "Prénom", "Genre", "Date de naissance", "Age", "Telephone", "Email", "Droit à l'image ?"]
    column_headers << "Exclu ?" if academy.banished
    column_headers << "Paiement effectué ?" if school_period.paid
    column_headers << "T-hsirt reçu ?" if school_period.tshirt
    column_headers.concat(["Activité 1", "Taux abs 1", "Activité 2", "Taux abs 2", "Activité 3", "Taux abs 3"])

    respond_to do |format|
      format.csv do
        csv_data = CSV.generate(col_sep: ';', encoding: 'UTF-8') do |csv|
          csv << column_headers

          students.each do |student|
            camp_enrollment = student.camp_enrollments.find_by(camp: camp)
            image_consent = camp_enrollment.image_consent ? "Oui" : "Non"
            banished = camp_enrollment.banished ? "Oui" : "Non" if academy.banished
            paid = camp_enrollment.paid ? "Oui" : "Non" if school_period.paid
            school_periods = student.school_periods.where(academy: academy)
            school_period_enrollments = student.school_period_enrollments.where(school_period: school_periods)
            thsirt_delivered = school_period_enrollments.any?(&:tshirt_delivered) ? "Oui" : "Non" if school_period.tshirt
            activities = student.student_activities(camp)

            student_data = [
              student.last_name, student.first_name, student.gender, student.date_of_birth,
              student.age, student.phone_number, student.email, image_consent
            ]

            student_data << banished if academy.banished
            student_data << paid if school_period.paid
            student_data << thsirt_delivered if school_period.tshirt

            student_data.concat([
              activities.first&.name, student.unattended_activity_rate(activities.first),
              activities.second&.name, student.unattended_activity_rate(activities.second),
              activities.third&.name, student.unattended_activity_rate(activities.third)
            ])

            csv << student_data
          end
        end
        send_data(csv_data, filename: "#{academy.name}_#{school_period.name}_#{school_period.year}_#{camp.name}_élèves_inscrits.csv")
      end
    end
  end

  def export_banished_students_csv
    academy = Academy.find(params[:id])
    camp = Camp.find(params[:camp_id])
    banished_students = camp.banished_students.sort_by(&:last_name)

    authorize([:managers, camp])
    respond_to do |format|
      format.csv do
        csv_data = CSV.generate(col_sep: ';', encoding: 'UTF-8') do |csv|
          csv << ["Nom", "Prénom", "Genre", "Date de naissance", "Age", "Telephone", "Email"]

          banished_students.each do |student|
            csv << [student.last_name, student.first_name, student.gender, student.date_of_birth, student.age, student.phone_number, student.email]
          end
        end

        send_data(csv_data, filename: "#{academy.name}_#{camp.school_period.name}_#{camp.school_period.year}_#{camp.name}_élèves_exclus.csv")
      end
    end
  end

  private

  def set_cache_headers
    response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate" # Empêche la mise en cache
    response.headers["Pragma"] = "no-cache" # Pour les versions HTTP 1.0
    response.headers["Expires"] = "0" # Proscrit l'utilisation d'une copie mise en cache
  end

  def camp_params
    params.require(:camp).permit(:name, :starts_at, :ends_at, :capacity, :waitlist_capacity)
  end
end
