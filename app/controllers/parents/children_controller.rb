class Parents::ChildrenController < Parents::BaseController
  before_action :set_parent

  def index
    @existing_children = Student.where(id: session[:existing_children]) if session[:existing_children].present?
    @children = policy_scope([:parents, Student])
    @start_year = Date.current.month >= 9 ? Date.current.year : Date.current.year - 1
    authorize [:parents, :student], :index?
  end

  def assign_children
    authorize [:parents, :student], :assign_children?
    children = Student.where(id: params[:child_ids])
    if children.any?
      children.update_all(user_id: current_user.id, email: current_user.email, address: current_user.parent_profile.address, zipcode: current_user.parent_profile.zipcode, city: current_user.parent_profile.city, phone_number: current_user.phone_number)

      flash[:notice] = "Les enfants ont été ajoutés avec succès."
    else
      flash[:alert] = "Aucun enfant sélectionné."
    end
    session.delete(:existing_children)
    redirect_to parents_children_path
  end


  def new
    @child = Student.new
    @parent = current_user
    authorize [:parents, :student], :new?
  end

  def create
    @child = Student.new(child_params)
    authorize [:parents, :student], :create?

    # Calcul du username basé sur la date de naissance
    excel_serial_date = (@child.date_of_birth - Date.new(1899, 12, 30)).to_i
    username = "#{@child.first_name.downcase}#{@child.last_name.downcase}#{excel_serial_date}"

    # Vérifie si un étudiant avec ce username existe déjà
    existing_child = Student.find_by(username: username)

    if existing_child
      @child = existing_child

      # Met à jour uniquement les champs qui ne sont pas déjà définis
      child_params.each do |key, value|
        @child[key] = value if @child.respond_to?(key) && @child[key].blank?
      end

      # Définir un message spécifique pour un enfant retrouvé et mis à jour
      notice_message = "L'enfant a bien été retrouvé et mis à jour."
    else
      @child.username = username
      notice_message = "Le profil de l'enfant a été créé."
    end

    @child.parent = @parent
    if @child.save
      @child.update(email: @parent.email, phone_number: @parent.phone_number, address: @parent.parent_profile.address, zipcode: @parent.parent_profile.zipcode, city: @parent.parent_profile.city)
      redirect_to parents_children_path, notice: notice_message
    else
      render :new, alert: "Une erreur est survenue lors de la création du profil de l'enfant."
    end
  end

  def show
    @child = Student.find(params[:id])
    authorize [:parents, :student], :show?
    @start_year = Date.current.month >= 9 ? Date.current.year : Date.current.year - 1
    @membership = @child.memberships.find_by(start_year: @start_year)
    @memberships = @child.memberships.order(start_year: :desc)
    @camp_enrollments = @child.payable_camp_enrollments.includes(:camp).order('camps.starts_at DESC')
    @annual_program_enrollments = @child.annual_program_enrollments.includes(:annual_program).order('annual_programs.starts_at DESC')
    # @camp_enrollment = @camp_enrollments.last

  end

  def edit
    @child = Student.find(params[:id])
    authorize [:parents, :student], :edit?
  end

  def update
    @child = Student.find(params[:id])
    authorize [:parents, :student], :update?
    if @child.update(child_params)
      redirect_to parents_child_path(@child), notice: "Le profil de l'enfant a été mis à jour"
    else
      render :edit, alert: "Une erreur est survenue lors de la mise à jour du profil de l'enfant."
    end
  end

  private

  def set_parent
    @parent = current_user
    @parent_profile = @parent.parent_profile
  end

  def child_params
    params.require(:student).permit(:first_name, :last_name, :date_of_birth, :gender, :photo, :email, :phone_number, :school, :has_medical_treatment, :medical_treatment_description, :has_consent_for_photos, :rules_signed, :address, :zipcode, :city, :allergy, academy_ids: [])
  end

end
