class Managers::CampsController < ApplicationController
  def show
    @camp = Camp.find(params[:id])
    @academy = @camp.school_period.academy
    authorize([:managers, @camp])
    @activities = @camp.activities
    @activity = Activity.new
    @students = @camp.students_with_activity_enrollment
  end

  def create
    @camp = Camp.new(camp_params)
    @camp.school_period = SchoolPeriod.find(params[:school_period_id])
    authorize([:managers, @camp])

    if @camp.save
      flash[:notice] = "Camp créé"
    else
      flash[:alert] = "Erreur : " + @camp.errors.full_messages.join(", ")
    end

    redirect_to managers_school_period_path(@camp.school_period)
  end

  def destroy
    @camp = Camp.find(params[:id])
    authorize([:managers, @camp])
    @camp.destroy
    redirect_to managers_school_period_path(@camp.school_period)
    flash[:notice] = "Semaine supprimée"
  end

  def export_students_csv
    @camp = Camp.find(params[:id])
    authorize([:managers, @camp])
    students = @camp.students_with_activity_enrollment.sort_by { |student| student.unattended_rate(student.student_activities(@camp).first) }

    respond_to do |format|
      format.csv do
        headers['Content-Disposition'] = "attachment; filename=\"eleves_inscrits.csv\""
        headers['Content-Type'] = 'text/csv; charset=UTF-8'

        csv_data = CSV.generate(col_sep: ';', encoding: 'UTF-8') do |csv|
          csv << ["Nom", "Prénom", "Age", "Activité 1", "Taux abs 1", "Activité 2", "Taux abs 2"]

          students.each do |student|
            csv << [student.last_name, student.first_name, student.age, student.student_activities(@camp).first.name, student.unattended_rate(student.student_activities(@camp).first), student.student_activities(@camp).second&.name, student.unattended_rate(student.student_activities(@camp).second)]
          end
        end

        send_data(csv_data, filename: "eleves_inscrits.csv")
      end
    end
  end

  def export_banished_students_csv
    academy = Academy.find(params[:id])
    camp = academy.camps.where("starts_at <= ? AND ends_at >= ?", Time.current, Time.current).first
    if camp.present?
      banished_students = camp.banished_students.sort_by(&:last_name)
    else
      banished_students = []
    end
    authorize([:managers, @camp])
    # exporter au format csv la liste des banished_students avec le last_name, le forst_name, le phone_number et le eamil
    respond_to do |format|
      format.csv do

        headers['Content-Type'] = 'text/csv; charset=UTF-8'
        headers['Content-Disposition'] = 'attachment; filename=eleves_exclus.csv'

        csv_data = CSV.generate(col_sep: ';', encoding: 'UTF-8') do |csv|
          csv << ["Nom", "Prénom", "Telephone", "Email"]

          banished_students.each do |student|
            csv << [student.last_name, student.first_name, student.phone_modified, student.email]
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
