class Parents::ProfilesController < Parents::BaseController
  def new
    @parent = current_user
    authorize [:parents, :profiles], :new?
    @parent_profile = ParentProfile.new
  end

  def create
    @parent = current_user
    authorize [:parents, :profiles], :new?
    @parent_profile = ParentProfile.new(parent_profile_params)

    @parent_profile.user = @parent
    @parent.update(phone_number: @parent_profile.phone_number)
    email = @parent.email
    existing_children = Student.where(email: email)

    # si ya des enfants on redirige vers une page avec les enfants retrouvés
    # sinon on conserve la redirection vers new_parents_profile_path,
    if @parent_profile.save
      @parent.update!(first_login: false)
      session[:existing_children] = existing_children.map(&:id) if existing_children.present?
      redirect_to parents_children_path, notice: 'Votre profil a bien été créé.'
    else
      redirect_to new_parents_profile_path, alert: 'Une erreur est survenue.'
    end
  end

  def show
    @parent = current_user
    @parent_profile = @parent.parent_profile
    authorize [:parents, :profiles], :show?
  end

  def edit
    @parent = current_user
    @parent_profile = @parent.parent_profile
    authorize [:parents, :profiles], :edit?
  end

  def update
    @parent = current_user
    @parent_profile = @parent.parent_profile
    authorize [:parents, :profiles], :update?
    if @parent_profile.update(parent_profile_params)
      redirect_to parents_profile_path, notice: 'Votre profil a bien été mis à jour.'
    else
      render :edit, alert: 'Une erreur est survenue lors de la modification du profil.'
    end
  end

  private

  def parent_profile_params
    params.require(:parent_profile).permit(:gender, :relationship_to_child, :phone_number, :address, :zipcode, :city, :has_valid_rgpd, :has_newsletter)
  end
end
