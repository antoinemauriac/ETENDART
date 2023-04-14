class Managers::DashboardsController < ApplicationController
  def index
    @academies = current_user.academies_as_manager
    @today_courses = Course.today(current_user).sort_by(&:starts_at)
    @tomorrow_courses = Course.tomorrow(current_user).sort_by(&:starts_at)
    @feedbacks = Feedback.last_five(current_user)
    @today_absent_students = Student.today_absent_students(current_user)

    skip_policy_scope
    authorize([:managers, @academies], policy_class: Managers::DashboardPolicy)
  end
end
