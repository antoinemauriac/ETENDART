class SchoolPeriodsController < ApplicationController
  def show
    authorize SchoolPeriod
    @academy = Academy.find(params[:academy_id])
    @school_period = @academy.school_periods.find(params[:id])
    @parent = current_user
    @children = @parent.children
  end
end
