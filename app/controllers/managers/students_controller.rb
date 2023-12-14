class Managers::StudentsController < ApplicationController
  require 'csv'
  require 'open-uri'

  def index
    @academy = Academy.find(params[:academy])

    if params[:query].present?
      @students = Student.search_by_query(params[:query])
                         .joins(academy_enrollments: :academy)
                         .where(academies: { id: @academy.id })
                         .order(:last_name)
    else
      @students = Student.joins(academy_enrollments: :academy)
                         .where(academies: { id: @academy.id })
                         .order(:last_name)
                         .distinct
    end

    @pagy, @students = pagy(@students, items: 100)
    skip_policy_scope
    authorize([:managers, @students], policy_class: Managers::StudentPolicy)
    respond_to do |format|
      format.html
      format.text { render partial: "managers/students/list", locals: {students: @students}, formats: [:html] }
    end
  end

  def show
    @student = Student.find(params[:id])
    authorize([:managers, @student], policy_class: Managers::StudentPolicy)
    @academies = current_user.academies_as_manager
    @academy = Academy.find(params[:academy_id])
    @feedback = Feedback.new
    @feedbacks = @student.feedbacks.order(created_at: :desc)
    @next_camp_activities = @student.next_camp_activities.reject { |activity| @student.next_courses_by_activity(activity).empty? }
    @next_annual_activities = @student.next_annual_activities.reject { |activity| @student.next_courses_by_activity(activity).empty? }
    next_courses = @student.next_courses
    @next_annual_courses = next_courses.select(&:annual_program)
    @next_camp_courses = next_courses.select(&:camp)
    past_courses = @student.past_courses
    @past_annual_courses = past_courses.select(&:annual_program)
    @past_camp_courses = past_courses.select(&:camp)
  end

  def new
    @student = Student.new
    authorize([:managers, @student], policy_class: Managers::StudentPolicy)
    @academy = Academy.find(params[:academy_id])
  end

  def create
    student = Student.new(student_params)
    authorize([:managers, student], policy_class: Managers::StudentPolicy)
    student.academies << Academy.find(params[:student][:academy1_id])
    student.academies << Academy.find(params[:student][:academy2_id]) if params[:student][:academy2_id].present?
    student.academies << Academy.find(params[:student][:academy3_id]) if params[:student][:academy3_id].present?
    academy = Academy.find(params[:student][:academy1_id])
    excel_serial_date = (student.date_of_birth - Date.new(1899, 12, 30)).to_i
    username = "#{student.first_name.downcase}#{student.last_name.downcase}#{excel_serial_date }"
    student.update(username: username)
    if student.save
      redirect_to managers_student_path(student, academy_id: academy.id)
      flash[:notice] = "Élève ajouté"
    else
      flash[:error] = "Une erreur est survenue"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @student = Student.find(params[:id])
    @academy1 = @student.academies.first if @student.academies.any?
    @academy2 = @student.academies.second if @student.academies.second
    @academy3 = @student.academies.third if @student.academies.third
    @academy = @student.first_academy
    authorize([:managers, @student], policy_class: Managers::StudentPolicy)
  end

  def update
    student = Student.find(params[:id])
    authorize([:managers, student], policy_class: Managers::StudentPolicy)
    if student.update(student_params)
      update_academies(student)
      redirect_to managers_student_path(student, academy_id: student.first_academy.id)
      flash[:notice] = "Informations modifiées avec succès"
    else
      flash[:error] = "Une erreur est survenue"
      redirect_to managers_student_path(student, academy_id: student.first_academy.id)
    end
  end

  def update_academies(student)
    student.academies.clear
    student.academies << Academy.find(params[:student][:academy1_id]) if params[:student][:academy1_id].present?
    student.academies << Academy.find(params[:student][:academy2_id]) if params[:student][:academy2_id].present?
    student.academies << Academy.find(params[:student][:academy3_id]) if params[:student][:academy3_id].present?
  end

  def update_photo
    @student = Student.find(params[:id])
    @origin = params[:origin]
    authorize([:managers, @student], policy_class: Managers::StudentPolicy)
    # Upload de l'image sur Cloudinary en utilisant l'upload_preset student_avatar
    result = Cloudinary::Uploader.upload(params[:student][:photo], upload_preset: 'student_avatar')

    # Récupération de l'URL de l'image uploadée
    photo_url = result['secure_url']

    # Enregistrement de l'URL de l'image sur l'objet Student
    @student.photo.attach(io: URI.open(photo_url), filename: "avatar")

    @academy = Academy.find(params[:academy_id]) if params[:academy_id].present?

    if params[:redirect_to] === 'manager'
      redirect_to managers_student_path(@student, academy_id: @academy.id), notice: "Photo mise à jour"
    else
      redirect_to coaches_student_profile_path(@student, precedent: @origin), notice: "Photo mise à jour"
    end
  end

  def export_students_csv
    academy = Academy.find(params[:id])
    students = academy.students
    authorize([:managers, @students], policy_class: Managers::StudentPolicy)
    respond_to do |format|
      format.csv do

        csv_data = CSV.generate(col_sep: ';', encoding: 'UTF-8') do |csv|
          csv << ["Nom", "Prénom", "Genre", "Telephone", "Email", "Date de naissance", "Adresse", "Code postal", "Ville"]

          students.each do |student|
            csv << [student.last_name, student.first_name, student.gender, student.phone_number, student.email, student.date_of_birth, student.address, student.zipcode, student.city]
          end
        end

        send_data(csv_data, filename: "eleves_#{academy.name}.csv")
      end
    end
  end

  private

  def student_params
    params.require(:student).permit(:username, :first_name, :last_name, :email, :date_of_birth, :gender, :phone_number, :city, :zipcode, :address, :photo)
  end

end
