class Coaches::DashboardsController < ApplicationController
  def index
    @academies = current_user.academies_as_coach
    skip_policy_scope
    authorize([:coaches, @academies], policy_class: Coaches::DashboardPolicy)
    @next_activities = current_user.next_activities
    @next_courses = current_user.next_courses.limit(5)
  end
end
