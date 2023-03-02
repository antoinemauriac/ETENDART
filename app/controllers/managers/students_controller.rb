class Managers::StudentsController < ApplicationController
  require 'csv'

  def index
    @students = Student.joins(academy_enrollments: :academy)
                       .where(academies: { manager_id: current_user.id })
                       .distinct
    skip_policy_scope
    authorize([:managers, @students], policy_class: Managers::StudentPolicy)
  end

  def show
    @student = Student.find(params[:id])
    authorize([:managers, @student], policy_class: Managers::StudentPolicy)
    @academies = @student.academies.uniq
  end

  def new
    @student = Student.new
    authorize([:managers, @student], policy_class: Managers::StudentPolicy)
  end

  def create
    @student = Student.new(student_params)
    authorize([:managers, @student], policy_class: Managers::StudentPolicy)
    @student.academies << Academy.find(params[:student][:academy1_id])
    @student.academies << Academy.find(params[:student][:academy2_id]) if params[:student][:academy2_id].present?
    if @student.save
      redirect_to managers_student_path(@student)
      flash[:notice] = "Élève ajouté"
    else
      flash[:error] = "Une erreur est survenue"
      render :new, status: :unprocessable_entity
    end
  end

  def import
    school_period = SchoolPeriod.find(params[:school_period_id])
    authorize([:managers, @school_period], policy_class: Managers::StudentPolicy)
    academy = school_period.academy
    file = params[:csv_file]
    file = File.open(file)
    csv = CSV.parse(file, headers: true, col_sep: ';')

    csv.each do |row|
      row = row.to_hash

      student = Student.find_or_initialize_by(username: row['username'])
      student.assign_attributes(student_params_upload(row))

      if student.new_record?
        student.save
      else
        student.update(student_params_upload(row))
      end

      student.academies << academy unless student.academies.include?(academy)
      student.school_periods << school_period unless student.school_periods.include?(school_period)

      (1..4).each do |week_number|
        week_name = "semaine#{week_number}"
        if row[week_name] == "oui"
          week_camp = school_period.camps.find_by(name: week_name)
          student.camps << week_camp unless student.camps.include?(week_camp)

          activity_name = row["activite_#{week_name}"]
          if activity_name.present?
            activity = week_camp.activities.find_by(name: activity_name)
            if activity.present?
              student.courses << activity.courses unless student.activities.include?(activity)
              student.activities << activity unless student.activities.include?(activity)
            else
              flash[:alert] = "Une erreur est survenue. L'activité #{activity_name} ne correspond pas à une activité créée sur l'application"
              redirect_to managers_school_period_path(school_period) and return
            end
          end
        end
      end
    end

    redirect_to managers_school_period_path(school_period), notice: "Le fichier CSV a été importé avec succès."
  end

  private

  def student_params
    params.require(:student).permit(:username, :first_name, :last_name, :email, :date_of_birth, :gender)
  end

  def student_params_upload(row)
    row = row.transform_keys { |key| key == 'prénom' ? 'first_name' : key == 'nom' ? 'last_name' : key == 'date-naissance' ? 'date_of_birth' : key == 'genre' ? 'gender' : key}
    ActionController::Parameters.new(row).permit(:username, :first_name, :last_name, :email, :date_of_birth, :gender)
  end

end
