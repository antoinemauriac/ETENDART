class Coaches::StudentProfilesController < ApplicationController

  def show
    @student = Student.find(params[:id])
    @start_year = Date.current.month >= 3 ? Date.current.year : Date.current.year - 1
    @membership = @student.memberships.find_by(start_year: @start_year)
    authorize([:coaches, @student], policy_class: Coaches::StudentProfilePolicy)
    @feedbacks = @student.feedbacks.where(coach_id: current_user.id).order(created_at: :desc)
    @feedback = Feedback.new
    @url = params[:url_origin]
  end

  def index
    @students = current_user.students.sort_by { |student| student.last_name.try(:downcase) }
    skip_policy_scope
    authorize([:coaches, @students], policy_class: Coaches::StudentProfilePolicy)
  end
end
