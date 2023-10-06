class Coaches::CoursePolicy < ApplicationPolicy
  def index?
    user.coach? || user.manager?
  end

  def show?
    record.all_coaches.include?(user) || user.manager?
  end

  def update_enrollments?
    record.all_coaches.include?(user) || user.manager?
  end
end
