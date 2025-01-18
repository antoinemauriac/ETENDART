class Parents::ProfilesController < ApplicationController
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
    if @parent_profile.save
      stripe_customer = Stripe::Customer.create(
        address: {
          line1: @parent_profile.address,
          postal_code: @parent_profile.zipcode,
          city: @parent_profile.city,
          country: 'FR',
          state: 'France'
        },
        email: @parent.email,
        name: @parent.full_name,
        phone: @parent_profile.phone_number
      )
      @parent_profile.update!(stripe_customer_id: stripe_customer.id)
      @parent.carts.create!(status: 'pending')
      redirect_to parents_profile_path, notice: 'Votre profil a bien été créé.'
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
      Stripe::Customer.update(@parent_profile.stripe_customer_id,
        address: {
          line1: @parent_profile.address,
          postal_code: @parent_profile.zipcode,
          city: @parent_profile.city,
          country: 'FR',
          state: 'France'
        },
        email: @parent.email,
        name: @parent.full_name,
        phone: @parent_profile.phone_number
      )
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
