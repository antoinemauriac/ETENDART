class Managers::CampsController < ApplicationController
  def show
    @camp = Camp.find(params[:id])
    @school_period = @camp.school_period
    @academy = @school_period.academy
    authorize([:managers, @camp])
    @activities = @camp.activities
    @activity = Activity.new
    @students = @camp.students.order(:last_name)
  end

  def create
    camp = Camp.new(camp_params)
    camp.school_period = SchoolPeriod.find(params[:school_period])
    authorize([:managers, camp])

    if camp.save
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
    authorize([:managers, camp])
    students = camp.students.sort_by(&:last_name)

    respond_to do |format|
      format.csv do

        csv_data = CSV.generate(col_sep: ';', encoding: 'UTF-8') do |csv|
          csv << ["Nom", "Prénom", "Age", "Genre", "Droit à l'image", "Activité 1", "Taux abs 1", "Activité 2", "Taux abs 2", "Activité 3", "Taux abs 3"]
          students.each do |student|
            image_consent = !student.camp_enrollments.find_by(camp: camp).image_consent ? "Non" : "Oui"
            activities = student.student_activities(camp)
            csv << [student.last_name, student.first_name, student.age, student.gender, image_consent, activities.first.name, student.unattended_activity_rate(activities.first), activities.second&.name, student.unattended_activity_rate(activities.second), activities.third&.name, student.unattended_activity_rate(activities.third)]
          end
        end

        send_data(csv_data, filename: "#{camp.academy.name} - #{camp.school_period.name} - #{camp.name} - eleves_inscrits.csv")
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
          csv << ["Nom", "Prénom", "Genre", "Telephone", "Email"]

          banished_students.each do |student|
            csv << [student.last_name, student.first_name, student.gender, student.phone_number, student.email]
          end
        end

        send_data(csv_data, filename: "eleves_exclus.csv")
      end
    end
  end

  private

  def camp_params
    params.require(:camp).permit(:name, :starts_at, :ends_at)
  end
end

# camp = Camp.find(1)
# counter = 0
# camp.camp_enrollments.find_each do |camp_enrollment|
#   starts_at = camp.starts_at
#   student = camp_enrollment.student
#   past_camp_enrollments = student.camp_enrollments.joins(:camp).where('camps.starts_at < ?', starts_at)
#   if past_camp_enrollments.empty?
#     counter += 1
#   end
# end
