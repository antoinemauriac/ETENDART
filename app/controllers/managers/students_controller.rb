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
    @academies = current_user.academies
    @academy = @student.first_academy
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
    @start_year = Date.current.month >= 9 ? Date.current.year : Date.current.year - 1
    @membership = @student.memberships.find_by(start_year: @start_year)
    @memberships = @student.memberships.order(start_year: :desc)
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
    student.academies << Academy.find(params[:student][:academy1_id])
    student.academies << Academy.find(params[:student][:academy2_id]) if params[:student][:academy2_id].present?
    student.academies << Academy.find(params[:student][:academy3_id]) if params[:student][:academy3_id].present?
    academy = Academy.find(params[:student][:academy1_id])
    excel_serial_date = (student.date_of_birth - Date.new(1899, 12, 30)).to_i
    username = "#{student.first_name.downcase}#{student.last_name.downcase}#{excel_serial_date }"
    student.update(username: username)
    if student.save
      redirect_to managers_student_path(student)
      flash[:notice] = "Élève ajouté"
    else
      flash[:error] = "Une erreur est survenue"
      render :new, status: :unprocessable_entity
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
      update_academies(student)
      redirect_to managers_student_path(student)
      flash[:notice] = "Informations modifiées avec succès"
    else
      flash[:error] = "Une erreur est survenue"
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

    # Suppression de l'image originale sur Cloudinary
    Cloudinary::Uploader.destroy(public_id)

    @academy = Academy.find(params[:academy_id]) if params[:academy_id].present?

    respond_to do |format|
      format.html { redirect_to determine_redirect_path, notice: "Photo ajoutée" }
      format.json { render json: { imageUrl: url_for(@student.photo) } }
      format.text do
        partial = choose_partial_based_on_origin
        render partial: partial, locals: { student: @student }, formats: [:html]
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
    start_year = Date.current.month >= 9 ? Date.current.year : Date.current.year - 1
    authorize([:managers, @students], policy_class: Managers::StudentPolicy)
    respond_to do |format|
      format.csv do

        csv_data = CSV.generate(col_sep: ';', encoding: 'UTF-8') do |csv|
          csv << ["Nom", "Prénom", "Genre", "Date de naissance", "Age", "Telephone", "Email", "Adresse", "Code postal", "Ville", "Membre ?", "Dernier cours", "Sport Principal", "Academie du dernier cours"]

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
              student.memberships.where(start_year: start_year)&.first&.status ? "Oui" : "Non",
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
    params.require(:student).permit(:username, :first_name, :last_name, :email, :date_of_birth, :gender, :phone_number, :city, :zipcode, :address, :photo)
  end

  def determine_redirect_path
    if @origin == 'manager'
      managers_student_path(@student)
    else
      coaches_student_profile_path(@student, precedent: @origin)
    end
  end

  def choose_partial_based_on_origin
    case @origin
    when 'course'
      'coaches/courses/student_photo' # Chemin vers votre partial pour les managers
    when 'student_profile'
      'coaches/student_profiles/student_photo'  # Chemin par défaut ou pour les coaches
    end
  end

end
