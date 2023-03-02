class Coaches::StudentProfilesController < ApplicationController

  def show
    @student = Student.find(params[:id])
    authorize([:coaches, @student], policy_class: Coaches::StudentProfilePolicy)
    @feedbacks = @student.feedbacks.where(coach_id: current_user.id)
  end
end
