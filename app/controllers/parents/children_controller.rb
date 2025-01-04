class Parents::ChildrenController < ApplicationController
  before_action :set_parent

  def index
    @children = policy_scope([:parents, Student])
    authorize [:parents, :student], :index?
  end

  def new
    @child = Student.new
    authorize [:parents, :student], :new?
  end

  def create
    @child = Student.new(child_params)
    authorize [:parents, :student], :create?
    excel_serial_date = (@child.date_of_birth - Date.new(1899, 12, 30)).to_i
		username = "#{@child.first_name.downcase}#{@child.last_name.downcase}#{excel_serial_date }"

		# je check si ce username existe déjà dans la base
		existing_child = Student.find_by(username: username)

    # si il existe déjà, je ne crée pas de nouvelle instance de child
    # mais je mets à jour les infos rentrées par le parent concernant addresse, allergies, email...
    if existing_child
      @child = existing_child
      @child.update(child_params)

    # sinon je crée un nouveau child
    else
      @child.username = username
    end

    @child.parent = @parent
    if @child.save
      redirect_to parents_child_path(@child), notice: 'L\'élève a bien été créé.'
    else
      redirect_to new_parents_child_path, alert: 'Une erreur est survenue lors de la création de l\'élève.'
    end
  end

  def show
    @child = Student.find(params[:id])
    authorize [:parents, :student], :show?
  end

  def edit
    @child = Student.find(params[:id])
    authorize [:parents, :student], :edit?
  end

  def update
    @child = Student.find(params[:id])
    authorize [:parents, :student], :update?
    if @child.update(child_params)
      redirect_to parents_child_path(@child), notice: 'L\'élève a bien été mis à jour.'
    else
      render :edit, alert: 'Une erreur est survenue lors de la modification de l\'élève.'
    end
  end

  private

  def set_parent
    @parent = current_user
    @parent_profile = @parent.parent_profile
  end

  def child_params
    params.require(:child).permit(:first_name, :last_name, :date_of_birth, :gender, :photo, :siblings_count, :email, :phone_number, :school, :has_medical_treatment, :medical_treatment_description, :has_consent_for_photos, :rules_signed)
  end

end
