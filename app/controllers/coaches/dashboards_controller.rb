class Coaches::DashboardsController < ApplicationController
  before_action :set_cache_headers, only: [:index]
  def index
    @academies = current_user.academies_as_coach
    skip_policy_scope
    authorize([:coaches, @academies], policy_class: Coaches::DashboardPolicy)
    # @next_activities = current_user.next_activities
    @next_courses = current_user.next_courses.limit(3)
    @today_courses = current_user.today_courses
    @students = current_user.students.uniq.sample(3)
    @missing_attendes = current_user.missing_attendance
  end

  private

  def set_cache_headers
    response.headers["Cache-Control"] = "no-cache, no-store, must-revalidate" # Empêche la mise en cache
    response.headers["Pragma"] = "no-cache" # Pour les versions HTTP 1.0
    response.headers["Expires"] = "0" # Proscrit l'utilisation d'une copie mise en cache
  end
end
