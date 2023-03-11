class Managers::DashboardsController < ApplicationController
  def index
    @academies = current_user.academies_as_manager
    @today_courses = Course.today(current_user)
    @feedbacks = Feedback.last_five(current_user)
    @absent_students = Student.absent_students(current_user)

    skip_policy_scope
    authorize([:managers, @academies], policy_class: Managers::DashboardPolicy)
  end
end
