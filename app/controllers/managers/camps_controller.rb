class Managers::CampsController < ApplicationController
  def show
    @camp = Camp.find(params[:id])
    @activities = @camp.activities
    @activity = Activity.new
  end

  def create
    @camp = Camp.new(camp_params)
    @camp.school_period = SchoolPeriod.find(params[:school_period_id])
    if @camp.save
      redirect_to managers_school_period_path(@camp.school_period)
      flash[:notice] = "Camp créé"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def camp_params
    params.require(:camp).permit(:name, :starts_at, :ends_at)
  end
end
