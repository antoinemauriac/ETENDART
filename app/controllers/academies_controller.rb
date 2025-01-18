class AcademiesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :index, :show ]

  def index
    @academies = policy_scope(Academy)
  end

  def show
    authorize Academy
    @academy = Academy.find(params[:id])
  end
end
