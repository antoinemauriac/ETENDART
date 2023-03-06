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
    if Geocoder.search(@location.address).any?
      @location.city = Geocoder.search(@location.address).first.city if Geocoder.search(@location.address).first.city
      @location.zipcode = Geocoder.search(@location.address).first.postal_code if Geocoder.search(@location.address).first.postal_code
      @location.country = Geocoder.search(@location.address).first.country if Geocoder.search(@location.address).first.country
    end
    if @location.save
      redirect_to managers_academy_locations_path(@academy)
      flash[:notice] = "Nouvelle adresse créé"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def location_params
    params.require(:location).permit(:address, :name)
  end
end
