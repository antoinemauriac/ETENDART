class Managers::SchoolPeriodsController < ApplicationController


  def create
    @academy = Academy.find(params[:academy_id])
    @school_period = @academy.school_periods.build(school_period_params)
    authorize([:managers, @school_period])
    if @school_period.save
      redirect_to managers_academy_path(@academy)
      flash[:notice] = "Période scolaire créée"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @school_period = SchoolPeriod.find(params[:format])
    authorize([:managers, @school_period])
    @camp = Camp.new
  end


  def school_period_params
    params.require(:school_period).permit(:name, :year)
  end

end
