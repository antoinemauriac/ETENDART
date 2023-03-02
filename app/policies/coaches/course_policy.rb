class Coaches::CoursePolicy < ApplicationPolicy
  def index?
    user.coach? || user.manager?
  end

  def show?
    user.coach? || user.manager?
  end

  def update_enrollments?
    user.coach? || user.manager?
  end
end
