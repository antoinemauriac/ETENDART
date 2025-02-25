class Parents::AcademiesController < ApplicationController
  def index
    @academies = policy_scope([:parents, Academy])
  end

  def show
    authorize([:parents, Academy])
    @academy = Academy.includes(:school_periods, :locations, :camps, :activities_through_camps).find(params[:id])
    @school_period = @academy.next_school_periods.first
  end
end
