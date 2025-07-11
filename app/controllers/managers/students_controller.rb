class Managers::StudentsController < ApplicationController
  require 'csv'
  require 'open-uri'

  def index
    @academy = Academy.find(params[:academy])
    # @start_year = Date.current.month >= 9 ? Date.current.year : Date.current.year - 1

    @students = if params[:query].present?
                  Student.search_by_query(params[:query])
                        .joins(academy_enrollments: :academy)
                        .where(academies: { id: @academy.id })
                else
                  Student.joins(academy_enrollments: :academy)
                        .where(academies: { id: @academy.id })
                        .distinct
                end

    @students = @students.reorder(last_name: :asc)


    @pagy, @students = pagy(@students, items: 30)
    skip_policy_scope
    authorize([:managers, @students], policy_class: Managers::StudentPolicy)
    respond_to do |format|
      format.html
      format.text { render partial: "managers/students/list", locals: {students: @students}, formats: [:html] }
    end
  end

  def index_for_admin
    if params[:academy].present? && params[:academy] != "all"
      @academy = Academy.find(params[:academy])
      @students = Student.joins(academy_enrollments: :academy)
                         .where(academies: { id: @academy.id })
                         .distinct
      @students = @students.search_by_query(params[:query]) if params[:query].present?
    else
      @students = params[:query].present? ? Student.search_by_query(params[:query]) : Student.all
    end
    @students = @students.reorder(last_name: :asc)
    @pagy, @students = pagy(@students, items: 30)
    skip_policy_scope
    authorize([:managers, @students], policy_class: Managers::StudentPolicy)
    respond_to do |format|
      format.html
      format.text { render partial: "managers/students/list_for_admin", locals: {students: @students, pagy: @pagy}, formats: [:html] }
    end
  end

  def show
    @student = Student.find(params[:id])
    authorize([:managers, @student], policy_class: Managers::StudentPolicy)
    @academies = (current_user.academies + @student.academies).uniq
    @academy1 = @student.academies.first if @student.academies.any?
    @academy2 = @student.academies.second if @student.academies.second
    @academy3 = @student.academies.third if @student.academies.third
    @academy = @student.first_academy
    @feedback = Feedback.new
    @feedbacks = @student.feedbacks.order(created_at: :desc)
    @start_year = Date.current.month >= 9 ? Date.current.year : Date.current.year - 1
    @membership = @student.memberships.find_by(start_year: @start_year)
    @memberships = @student.memberships.includes(:receiver).order(start_year: :desc)
    @camp_enrollments = @student.payable_camp_enrollments.includes(:camp, :receiver)
    @annual_program_enrollments = @student.payable_annual_program_enrollments.includes(:annual_program, :receiver)
    @camp_enrollment = @camp_enrollments.last
  end

  def current_activities
    @student = Student.includes(:activity_enrollments, :course_enrollments).find(params[:id])
    authorize([:managers, @student], policy_class: Managers::StudentPolicy)
    @academies = current_user.academies

    @next_camp_activities = @student.next_camp_activities.includes(:camp, :school_period)
    @next_annual_activities = @student.next_annual_activities.includes(:annual_program)
    next_courses = @student.next_courses.includes(:activity, :camp, :school_period, :annual_program)

    @next_annual_courses = next_courses.where(annual: true)
    @next_camp_courses = next_courses.where(annual: false)
    render partial: "managers/students/current_activities", locals: { student: @student }
  end

  def past_activities
    @student = Student.find(params[:id])
    authorize([:managers, @student], policy_class: Managers::StudentPolicy)
    past_courses = @student.past_courses.includes(:course_enrollments)
    @past_annual_courses = past_courses.where(annual: true)
    @past_camp_courses = past_courses.where(annual: false)
    render partial: "managers/students/past_activities", locals: { student: @student }
  end
  def new
    @student = Student.new
    authorize([:managers, @student], policy_class: Managers::StudentPolicy)
    @academy = Academy.find(params[:academy_id])
    @academies = current_user.academies
  end

  def create
    student = Student.new(student_params)
    authorize([:managers, student], policy_class: Managers::StudentPolicy)
    @academy = Academy.find(params[:student][:academy1_id]) if params[:student][:academy1_id].present?
    student.academies << Academy.find(params[:student][:academy1_id])
    student.academies << Academy.find(params[:student][:academy2_id]) if params[:student][:academy2_id].present?
    student.academies << Academy.find(params[:student][:academy3_id]) if params[:student][:academy3_id].present?
    excel_serial_date = (student.date_of_birth - Date.new(1899, 12, 30)).to_i
    username = "#{student.first_name.downcase}#{student.last_name.downcase}#{excel_serial_date}"
    student.username = username
    if student.save
      redirect_to managers_student_path(student)
      flash[:notice] = "Élève ajouté"
    else
      flash[:alert] = student.errors.full_messages.join(", ")
      redirect_to new_managers_student_path(academy: @academy.id)
    end
  end

  def edit
    @student = Student.find(params[:id])
    @academies = current_user.academies
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
      update_academies(student) if params[:student][:academy1_id].present?
      flash[:notice] = "Informations modifiées avec succès"
      redirect_to managers_student_path(student)
    else
      flash[:alert] = "Une erreur est survenue"
      redirect_to managers_student_path(student)
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
    @course = Course.find(params[:course_id]) if params[:course_id].present?

    authorize([:managers, @student], policy_class: Managers::StudentPolicy)

    # Supprimer l'ancienne photo de Cloudinary si elle existe
    if @student.photo.attached?
      @student.photo.purge
    end

    # Upload de la nouvelle image sur Cloudinary en utilisant l'upload_preset student_avatar
    result = Cloudinary::Uploader.upload(params[:student][:photo], upload_preset: 'student_avatar')

    # Récupération de l'URL et de l'ID public de la nouvelle image uploadée
    photo_url = result['secure_url']
    public_id = result['public_id']

    # Enregistrement de l'URL de la nouvelle image sur l'objet Student
    @student.photo.attach(io: URI.open(photo_url), filename: "avatar_student_id_#{@student.id}")

    # Suppression de l'image originale sur Cloudinary pour éviter le doublon dans le stockage
    Cloudinary::Uploader.destroy(public_id)

    @academy = Academy.find(params[:academy_id]) if params[:academy_id].present?

    respond_to do |format|
      format.html { redirect_to determine_redirect_path, notice: "Photo ajoutée" }
      format.json { render json: { imageUrl: url_for(@student.photo) } }
      format.text do
        partial = choose_partial_based_on_origin
        render partial: partial, locals: { student: @student, course: @course, origin: @origin }, formats: [:html]
      end
    end
  end

  def export_students_csv
    if params[:academy].present? && params[:academy] != "all"
      academy = Academy.find(params[:academy])
      students = academy.students.order(:last_name)
      filename = "eleves_#{academy.name}.csv"
    else
      students = Student.all.order(:last_name)
      filename = "eleves_toute_academie.csv"
    end
    authorize([:managers, @students], policy_class: Managers::StudentPolicy)
    respond_to do |format|
      format.csv do

        csv_data = CSV.generate(col_sep: ';', encoding: 'UTF-8') do |csv|
          csv << ["Nom", "Prénom", "Genre", "Date de naissance", "Age", "Telephone", "Email", "Adresse", "Code postal", "Ville", "Cotisant ?", "Dernier cours", "Sport Principal", "Academie du dernier cours"]

          students.each do |student|
            csv << [
              student.last_name,
              student.first_name,
              student.gender,
              student.date_of_birth,
              student.age, student.phone_number,
              student.email,
              student.address,
              student.zipcode,
              student.city,
              student.current_membership&.paid ? "Oui" : "Non",
              student.last_attended_course_date ? l(student.last_attended_course_date, format: :date) : '',
              student.predominant_sport,
              student.main_academy&.name
            ]
          end
        end

        send_data(csv_data, filename: filename)
      end
    end
  end

  private

  def student_params
    params.require(:student).permit(:username, :first_name, :last_name, :email, :date_of_birth, :gender, :phone_number, :city, :zipcode, :address, :photo, :has_consent_for_photos, :has_medical_treatment, :medical_treatment_description)
  end

  def determine_redirect_path
    if @origin == 'manager_student_profile'
      managers_student_path(@student)
    elsif @origin == 'coach_student_profile'
      coaches_student_profile_path(@student, precedent: @origin)
    end
  end

  def choose_partial_based_on_origin
    if @origin == 'manager_course' || @origin == 'coach_course'
      'coaches/courses/student_photo'
    elsif @origin == 'coach_student_profile' || @origin == 'manager_student_profile'
      'coaches/student_profiles/student_photo'
    end
  end

end
