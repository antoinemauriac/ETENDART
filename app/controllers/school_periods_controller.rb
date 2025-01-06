class SchoolPeriodsController < ApplicationController
  def show
    authorize SchoolPeriod
    @academy = Academy.find(params[:academy_id])
    @school_period = SchoolPeriod.find(params[:id])
  end
end
