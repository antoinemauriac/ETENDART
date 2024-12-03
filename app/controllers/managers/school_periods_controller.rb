class Managers::SchoolPeriodsController < ApplicationController

  def index
    @academy = Academy.find(params[:academy])
    @school_periods = @academy.school_periods.includes(:camps).sort_by { |sp| sp.starts_at }.reverse
    @school_period = SchoolPeriod.new(paid: true)
    skip_policy_scope
    authorize([:managers, @school_periods], policy_class: Managers::SchoolPeriodPolicy)
  end

  def index_for_admin
    @school_periods = SchoolPeriod.where(new: true).group_by { |school_period| [school_period.year, season_to_int(school_period.name)] }
    @school_periods = @school_periods.sort_by { |period, _| [-period[0], -period[1]] }
    skip_policy_scope
    authorize([:managers, :school_period])
  end

  def create
    academy = Academy.find(params[:academy])
    school_period = academy.school_periods.build(school_period_params)
    authorize([:managers, school_period])
    if school_period.save
      school_period.school_period_stat = SchoolPeriodStat.create(school_period: school_period)
      redirect_to managers_school_periods_path(academy: academy)
      flash[:notice] = "Période scolaire créée"
    else
      flash[:alert] = "Erreur : #{school_period.errors.full_messages.join(', ')}"
      redirect_to managers_school_periods_path(academy: academy)
    end
  end

  def show
    @school_period = SchoolPeriod.find(params[:id])
    @academy = @school_period.academy
    authorize([:managers, @school_period])
    @camp = Camp.new

    @activities = @school_period.activities.order(:camp_id)
    @camps = @school_period.camps.order(:starts_at)
  end

  def statistics
    @school_period = SchoolPeriod.find(params[:id])
    authorize([:managers, @school_period])

    @school_period_stat = @school_period.school_period_stat

    @academy = @school_period.academy
    @activities = @school_period.activities.includes(:courses).order(:camp_id)
    @camps = @school_period.camps

    @sorted_departments = @school_period_stat.participant_departments

    @category_ids = @school_period_stat.category_ids
  end

  def destroy
    school_period = SchoolPeriod.find(params[:id])
    academy = school_period.academy
    authorize([:managers, school_period])
    school_period.destroy
    redirect_to managers_school_periods_path(academy: academy)
    flash[:notice] = "Période scolaire supprimée"
  end

  private

  def school_period_params
    params.require(:school_period).permit(:name, :year, :paid, :price, :tshirt)
  end

  def season_to_int(season)
    case season.downcase
    when "février"
      1
    when "printemps"
      2
    when "été"
      3
    when "toussaint"
      4
    else
      0
    end
  end
end
