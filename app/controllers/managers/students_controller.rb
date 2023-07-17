class Managers::StudentsController < ApplicationController
  require 'csv'
  require 'open-uri'

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
    @academies = current_user.academies_as_manager
    @academy = Academy.find(params[:academy_id])
    @feedback = Feedback.new
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
    excel_serial_date = (@student.date_of_birth - Date.new(1899, 12, 30)).to_i
    username = "#{@student.first_name.downcase}#{@student.last_name.downcase}#{excel_serial_date }"
    @student.update(username: username)
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
    @academy = @student.first_academy
    authorize([:managers, @student], policy_class: Managers::StudentPolicy)
  end

  def update
    @student = Student.find(params[:id])
    authorize([:managers, @student], policy_class: Managers::StudentPolicy)
    if @student.update(student_params)
      update_academies
      redirect_to managers_student_path(@student, academy_id: @student.first_academy.id)
      flash[:notice] = "Informations modifiées avec succès"
    else
      flash[:error] = "Une erreur est survenue"
      render :edit, status: :unprocessable_entity
    end
  end

  def update_academies
    @student.academies.clear
    @student.academies << Academy.find(params[:student][:academy1_id]) if params[:student][:academy1_id].present?
    @student.academies << Academy.find(params[:student][:academy2_id]) if params[:student][:academy2_id].present?
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

    respond_to do |format|
      format.html do
        if params[:redirect_to] === 'manager'
          redirect_to managers_student_path(@student, academy_id: @academy.id), notice: "Photo mise à jour"
        else
          redirect_to coaches_student_profile_path(@student, precedent: @origin), notice: "Photo mise à jour"
        end
      end
      format.json { head :no_content }
    end
  end

  private

  def student_params
    params.require(:student).permit(:username, :first_name, :last_name, :email, :date_of_birth, :gender, :phone_number, :city, :zipcode, :address, :photo)
  end

end
