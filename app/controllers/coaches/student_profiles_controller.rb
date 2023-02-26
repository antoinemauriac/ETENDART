class Coaches::StudentProfilesController < ApplicationController

  def show
    @student = Student.find(params[:id])
    @feedbacks = @student.feedbacks.where(coach_id: current_user.id)
  end
end
