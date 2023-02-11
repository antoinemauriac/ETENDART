class Managers::SchoolPeriodsController < ApplicationController
  def index
    @academy = Academy.find(params[:academy_id])
    @school_periods = @academy.school_periods
  end

  def new
    @academy = Academy.find(params[:academy_id])
    @school_period = SchoolPeriod.new
  end

  def create
    @academy = Academy.find(params[:academy_id])
    @school_period = SchoolPeriod.new(school_period_params)
    @school_period.academy = @academy
    if @school_period.save
      redirect_to managers_academy_path(@academy)
      flash[:notice] = "Période scolaire créée"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @school_period = SchoolPeriod.find(params[:format])
  end

  def edit
    @school_period = SchoolPeriod.find(params[:id])
  end

  def update
    @school_period = SchoolPeriod.find(params[:id])
    if @school_period.update(school_period_params)
      redirect_to managers_academy_school_period_path(@school_period)
      flash[:notice] = "Période scolaire mise à jour"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def school_period_params
    params.require(:school_period).permit(:name, :year)
  end

end
