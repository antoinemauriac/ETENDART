class Managers::LocationsController < ApplicationController

  def create
    @location = Location.new(location_params)
    @location.academy = Academy.find(params[:academy_id])
    if @location.save
      redirect_to managers_academy_path(@location.academy)
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
