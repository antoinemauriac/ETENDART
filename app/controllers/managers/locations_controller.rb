class Managers::LocationsController < ApplicationController

  def index
    @academy = Academy.find(params[:academy_id])
    @locations = @academy.locations
    @location = Location.new
    skip_policy_scope
    authorize([:managers, @locations])
  end

  def create
    @location = Location.new(location_params)
    authorize([:managers, @location])
    @academy = Academy.find(params[:academy_id])
    @location.academy = @academy
    # if Geocoder.search(@location.address).first.present?
    #   result = Geocoder.search(@location.address).first
    #   @location.city = result.city if result.city
    #   @location.zipcode = result.postal_code if result.postal_code
    #   house_number = result.house_number if result.house_number
    #   street_name = result.road if result.road
    #   @location.street_address = "#{house_number}, #{street_name}" if house_number && street_name
    #   raise
    # end
    if @location.save
      redirect_to managers_academy_locations_path(@academy)
      flash[:notice] = "Nouvelle adresse créé"
    else
      render :new, status: :unprocessable_entity
      flash[:alert] = "Une erreur est survenue"
    end
  end

  def edit
    @location = Location.find(params[:id])
    @academy = Academy.find(params[:academy_id])
    authorize([:managers, @location])
  end

  def update
    @location = Location.find(params[:id])
    authorize([:managers, @location])
    # if Geocoder.search(@location.address).any?
    #   @location.city = Geocoder.search(@location.address).first.city if Geocoder.search(@location.address).first.city
    #   @location.zipcode = Geocoder.search(@location.address).first.postal_code if Geocoder.search(@location.address).first.postal_code
    #   @location.country = Geocoder.search(@location.address).first.country if Geocoder.search(@location.address).first.country
    # end
    if @location.update(location_params)
      redirect_to managers_academy_locations_path(@location.academy)
      flash[:notice] = "Adresse modifiée"
    else
      render :edit, status: :unprocessable_entity
      flash[:alert] = "Une erreur est survenue"
    end
  end

  private

  def location_params
    params.require(:location).permit(:address, :name)
  end
end
