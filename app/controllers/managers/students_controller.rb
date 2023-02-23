class Managers::StudentsController < ApplicationController
  require 'csv'

  def index
    @students = Student.joins(academy_enrollments: :academy)
                       .where(academies: { manager_id: current_user.id })
                       .distinct
  end

  def new
    @student = Student.new
  end

  def create
    @student = Student.new(student_params)
    @student.academies << Academy.find(params[:student][:academy1_id])
    @student.academies << Academy.find(params[:student][:academy2_id])
    if @student.save
      redirect_to managers_student_path(@student)
      flash[:notice] = "Élève ajouté"
    else
      flash[:error] = "Une erreur est survenue"
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @student = Student.find(params[:id])
  end


  def import
    school_period = SchoolPeriod.find(params[:school_period_id])
    file = params[:csv_file]
    file = File.open(file)
    csv = CSV.parse(file, headers: true, col_sep: ';')

    csv.each do |row|
      row = row.to_hash

      student = Student.find_or_initialize_by(username: row['username'])
      student.assign_attributes(student_params(row))

      if student.new_record?
        student.save
        student.academies << school_period.academy
      else
        student.update(student_params_upload(row))
      end

      academy = school_period.academy
      student.academies << academy unless student.academies.exists?(academy.id)

      (1..4).each do |week_number|
        week_name = "semaine#{week_number}"
        if row[week_name] == "oui"
          week_camp = school_period.camps.find_by(name: week_name)
          student.camps << week_camp unless student.camps.exists?(week_camp.id)

          activity_name = row["activite_#{week_name}"]
          if activity_name.present?
            activity = week_camp.activities.find_by(name: activity_name)
            student.activities << activity unless student.activities.exists?(activity.id)
            student.courses << activity.courses
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
    ActionController::Parameters.new(row).permit(:username, :first_name, :last_name, :email, :date_of_birth)
  end

end
