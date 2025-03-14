class Parents::ChildrenController < ApplicationController
  before_action :set_parent

  # path: parents_children_path
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
      children.update_all(user_id: current_user.id, email: current_user.email, address: current_user.parent_profile.address, zipcode: current_user.parent_profile.zipcode, city: current_user.parent_profile.city ) # Associe les enfants au parent avec email et adresse

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

      # Définir un message spécifique pour un nouvel enfant créé
      notice_message = "L'élève a bien été créé."
    end

    @child.parent = @parent
    if @child.save
      @child.must_pay_membership
      redirect_to parents_child_path(@child), notice: notice_message
    else
      render :new, alert: 'Une erreur est survenue lors de la création de l\'élève.'
    end
  end

  def show
    @child = Student.find(params[:id])
    authorize [:parents, :student], :show?
    @start_year = Date.current.month >= 9 ? Date.current.year : Date.current.year - 1
    @membership = @child.memberships.find_by(start_year: @start_year)
    @memberships = @child.memberships.includes(:receiver).order(start_year: :desc)
    @camp_enrollments = @child.payable_camp_enrollments.includes(:camp, :receiver)
    @camp_enrollment = @camp_enrollments.last

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
    params.require(:student).permit(:first_name, :last_name, :date_of_birth, :gender, :photo, :siblings_count, :email, :phone_number, :school, :has_medical_treatment, :medical_treatment_description, :has_consent_for_photos, :rules_signed, :address, :zipcode, :city, :allergy, academy_ids: [])
  end

end
