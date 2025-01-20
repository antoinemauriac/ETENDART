class Parents::ChildrenController < ApplicationController
  before_action :set_parent

  def index
    @children = policy_scope([:parents, Student])
    @start_year = Date.current.month >= 9 ? Date.current.year : Date.current.year - 1
    authorize [:parents, :student], :index?
  end

  def new
    @child = Student.new
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
      redirect_to parents_child_path(@child), notice: notice_message
    else
      render :new, alert: 'Une erreur est survenue lors de la création de l\'élève.'
    end
  end

  def show
    @child = Student.find(params[:id])
    authorize [:parents, :student], :show?
    @academies = @child.academies.uniq
    @academy1 = @child.academies.first if @child.academies.any?
    @academy2 = @child.academies.second if @child.academies.second
    @academy3 = @child.academies.third if @child.academies.third
    @academy = @child.first_academy
    @feedback = Feedback.new
    @feedbacks = @child.feedbacks.order(created_at: :desc)
    @start_year = Date.current.month >= 9 ? Date.current.year : Date.current.year - 1
    @membership = @child.memberships.find_by(start_year: @start_year)
    @memberships = @child.memberships.includes(:receiver).order(start_year: :desc)
    @camp_enrollments = @child.paid_camp_enrollments_without_free_judo_activity.includes(:camp, :receiver)
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
    params.require(:student).permit(:first_name, :last_name, :date_of_birth, :gender, :photo, :siblings_count, :email, :phone_number, :school, :has_medical_treatment, :medical_treatment_description, :has_consent_for_photos, :rules_signed, :address, :zipcode, :city, :allergy)
  end

end
