class Coaches::DashboardsController < ApplicationController
  def index
    @academies = current_user.academies_as_coach
    skip_policy_scope
    authorize([:coaches, @academies], policy_class: Coaches::DashboardPolicy)
    @next_activities = current_user.next_activities
    @next_courses = current_user.next_courses.limit(3)
    @missing_attendance = current_user.missing_attendance
    @students = current_user.students.sample(3)
  end
end
