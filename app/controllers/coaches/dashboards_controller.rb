class Coaches::DashboardsController < ApplicationController
  def index
    @academies = current_user.academies_as_coach
    skip_policy_scope
    authorize([:coaches, @academies], policy_class: Coaches::DashboardPolicy)
    @next_activities = current_user.next_activities
    @next_courses = current_user.next_courses.limit(3)
    @today_courses = current_user.today_courses
    @students = current_user.students.sample(3)
  end
end
