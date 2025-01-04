class Parents::ChildrenController < ApplicationController
  before_action :set_parent

  def index
    @children = policy_scope([:parents, Child])
    authorize [:parents, :child], :index?
  end

  def new
    @student = Student.new
    authorize [:parents, :student], :new?
  end

  def create
    @student = Student.new(student_params)
    authorize [:parents, :student], :create?
    excel_serial_date = (@student.date_of_birth - Date.new(1899, 12, 30)).to_i
		username = "#{@student.first_name.downcase}#{@student.last_name.downcase}#{excel_serial_date }"

		# je check si ce username existe déjà dans la base
		existing_student = Student.find_by(username: username)

    # si il existe déjà, je ne crée pas de nouvelle instance de student
    # mais je mets à jour les infos rentrées par le parent concernant addresse, allergies, email...
    if existing_student
      @student = existing_student
      @student.update(student_params)

    # sinon je crée un nouveau student
    else
      @student.username = username
    end

    @student.parent = @parent
    if @student.save
      redirect_to parents_student_path(@student), notice: 'L\'élève a bien été créé.'
    else
      redirect_to new_parents_student_path, alert: 'Une erreur est survenue lors de la création de l\'élève.'
    end
  end

  def show
    @student = Student.find(params[:id])
    authorize [:parents, :student], :show?
  end

  def edit
    @student = Student.find(params[:id])
    authorize [:parents, :student], :edit?
  end

  def update
    @student = Student.find(params[:id])
    authorize [:parents, :student], :update?
    if @student.update(student_params)
      redirect_to parents_student_path(@student), notice: 'L\'élève a bien été mis à jour.'
    else
      render :edit, alert: 'Une erreur est survenue lors de la modification de l\'élève.'
    end
  end

  private

  def set_parent
    @parent = current_user
    @parent_profile = @parent.parent_profile
  end

  def student_params
    params.require(:student).permit(:first_name, :last_name, :date_of_birth, :gender, :photo, :siblings_count, :email, :phone_number, :school, :has_medical_treatment, :medical_treatment_description, :has_consent_for_photos, :rules_signed)
  end

end
