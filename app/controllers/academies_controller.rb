class AcademiesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index, :show ]
  def index
    authorize Academy
    @academies = Academy.all
  end

  def show
    authorize Academy
    @academy = Academy.find(params[:id])
  end
end
