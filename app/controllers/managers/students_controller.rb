class Managers::StudentsController < ApplicationController
  require 'csv'

  def index
    @academy = Academy.find(params[:academy_id])
    @students = Student.joins(academy_enrollments: :academy)
                       .where(academies: @academy)
                       .distinct
    skip_policy_scope
    authorize([:managers, @students], policy_class: Managers::StudentPolicy)
  end

  def show
    @student = Student.find(params[:id])
    authorize([:managers, @student], policy_class: Managers::StudentPolicy)
    @academies = Academy.all
    @academy = Academy.find(params[:academy_id])
  end

  def new
    @student = Student.new
    authorize([:managers, @student], policy_class: Managers::StudentPolicy)
    @academy = Academy.find(params[:academy_id])
  end

  def create
    @student = Student.new(student_params)
    authorize([:managers, @student], policy_class: Managers::StudentPolicy)
    @student.academies << Academy.find(params[:student][:academy1_id])
    @student.academies << Academy.find(params[:student][:academy2_id]) if params[:student][:academy2_id].present?
    @academy = Academy.find(params[:student][:academy1_id])
    if @student.save
      redirect_to managers_student_path(@student, academy_id: @academy.id)
      flash[:notice] = "Élève ajouté"
    else
      flash[:error] = "Une erreur est survenue"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @student = Student.find(params[:id])
    @academy1 = @student.academies.first if @student.academies.any?
    @academy2 = @student.academies.second if @student.academies.count == 2
    authorize([:managers, @student], policy_class: Managers::StudentPolicy)
  end

  def update
    @student = Student.find(params[:id])
    authorize([:managers, @student], policy_class: Managers::StudentPolicy)
    if @student.update(student_params)
      update_academies
      redirect_to managers_student_path(@student)
      flash[:notice] = "Informations modifiées avec succès"
    else
      flash[:error] = "Une erreur est survenue"
      render :edit, status: :unprocessable_entity
    end
  end

  def import
    school_period = SchoolPeriod.find(params[:school_period][:school_period_id])
    authorize([:managers, school_period], policy_class: Managers::StudentPolicy)
    academy = school_period.academy
    file = params[:school_period][:csv_file]
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

      # retirer l'élève des cours de la période

      student.school_period_enrollments.where(school_period: school_period).destroy_all
      student.camp_enrollments.joins(:camp).where(camps: { school_period: school_period }).destroy_all
      student.activity_enrollments.joins(activity: :camp).where(camps: { school_period: school_period }).destroy_all
      student.course_enrollments.joins(course: { activity: :camp }).where(camps: { school_period: school_period }).destroy_all

      student.academies << academy unless student.academies.include?(academy)
      student.school_periods << school_period

      (1..4).each do |week_number|
        week_name = "semaine#{week_number}"
        if row[week_name] == "oui"
          week_camp = school_period.camps.find_by(name: week_name)
          student.camps << week_camp

          (1..2).each do |i|
            activity_name = row["activite_#{i}_#{week_name}"]
            if activity_name.present?
              activity = week_camp.activities.find_by(name: activity_name)
              if activity.present?
                student.activities << activity
                student.courses << activity.courses
              else
                flash[:alert] = "Une erreur est survenue. L'activité #{activity_name} ne correspond pas à une activité créée sur l'application"
                redirect_to managers_school_period_path(school_period) and return
              end
            end
          end
        end
      end
    end

    redirect_to managers_school_period_path(school_period), notice: "Le fichier CSV a été importé avec succès."
  end

  def update_academies
    @student.academies.clear
    @student.academies << Academy.find(params[:student][:academy1_id]) if params[:student][:academy1_id].present?
    @student.academies << Academy.find(params[:student][:academy2_id]) if params[:student][:academy2_id].present?
  end


  def update_photo
    @student = Student.find(params[:id])
    authorize([:managers, @student], policy_class: Managers::StudentPolicy)
    @student.photo.attach(params[:student][:photo])
    @academy = Academy.find(params[:academy_id]) if params[:academy_id].present?
    respond_to do |format|
      format.html do
        if params[:redirect_to] === 'manager'
          redirect_to managers_student_path(@student, academy_id: @academy.id), notice: "Photo mise à jour"
        else
          redirect_to coaches_student_profile_path(@student)
        end
      end
      format.json { head :no_content }
    end
  end

  private

  def student_params
    params.require(:student).permit(:username, :first_name, :last_name, :email, :date_of_birth, :gender, :phone_number, :city, :zipcode, :address, :photo)
  end

  def student_params_upload(row)
    row = row.transform_keys do |key|
      case key
      when 'prénom'
        'first_name'
      when 'nom'
        'last_name'
      when 'date-naissance'
        'date_of_birth'
      when 'genre'
        'gender'
      when 'tel'
        'phone_number'
      when 'ville'
        'city'
      when 'cp'
        'zipcode'
      when 'adresse'
        'address'
      else
        key
      end
    end
    ActionController::Parameters.new(row).permit(:username, :first_name, :last_name, :email, :date_of_birth, :gender, :phone_number, :city, :zipcode, :address)
  end

end
