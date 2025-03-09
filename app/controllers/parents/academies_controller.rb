class Parents::AcademiesController < ApplicationController
  def index
    @academies = policy_scope([:parents, Academy])
    @school_periods = SchoolPeriod.with_future_camps
    @academies = @academies.joins(:school_periods).where(school_periods: { id: @school_periods.pluck(:id) }).distinct
  end

  def show
    authorize([:parents, Academy])
    @academy = Academy.includes(:school_periods, :locations, :camps, :activities_through_camps).find(params[:id])
    @school_period = @academy.next_school_periods.first
  end
end
