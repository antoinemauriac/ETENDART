class Coaches::StudentProfilesController < ApplicationController

  def show
    @student = Student.find(params[:id])
    authorize([:coaches, @student], policy_class: Coaches::StudentProfilePolicy)
    @feedbacks = @student.feedbacks.where(coach_id: current_user.id).order(created_at: :desc)
    @feedback = Feedback.new
    @url = params[:url_origin]
  end

  def index
    @students = current_user.students
    skip_policy_scope
    authorize([:coaches, @students], policy_class: Coaches::StudentProfilePolicy)
  end
end
