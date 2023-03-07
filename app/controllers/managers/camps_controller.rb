class Managers::CampsController < ApplicationController
  def show
    @camp = Camp.find(params[:id])
    authorize([:managers, @camp])
    @activities = @camp.activities
    @activity = Activity.new
  end

  def create
    @camp = Camp.new(camp_params)
    @camp.school_period = SchoolPeriod.find(params[:school_period_id])
    authorize([:managers, @camp])
    if @camp.save
      redirect_to managers_school_period_path(@camp.school_period)
      flash[:notice] = "Camp créé"
    else
      redirect_to managers_school_period_path(@camp.school_period)
      flash[:alert] = "Une erreur est survenue"
    end
  end

  def destroy
    @camp = Camp.find(params[:id])
    authorize([:managers, @camp])
    @camp.destroy
    redirect_to managers_school_period_path(@camp.school_period)
    flash[:notice] = "Semaine supprimée"
  end

  def camp_params
    params.require(:camp).permit(:name, :starts_at, :ends_at)
  end
end
