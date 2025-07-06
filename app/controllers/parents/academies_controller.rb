class Parents::AcademiesController < Parents::BaseController
  skip_before_action :authenticate_user!, only: [:index, :show]

  def index
    @academies = policy_scope([:parents, Academy])
    @school_periods = SchoolPeriod.with_future_camps
    @academies = @academies.new_format.joins(:school_periods).where(school_periods: { id: @school_periods.pluck(:id) }).distinct.group_by { |academy| academy.city }
  end

  def show
    @academy = Academy.includes(:school_periods, :locations, :camps, :activities_through_camps).find(params[:id])
    authorize([:parents, @academy])
    @school_periods = SchoolPeriod.with_future_camps.where(academy_id: @academy.id)
  end
end
