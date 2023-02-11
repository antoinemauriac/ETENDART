class Managers::CampsController < ApplicationController
  def show
    @camp = Camp.find(params[:id])
    @activities = @camp.activities
  end
end
