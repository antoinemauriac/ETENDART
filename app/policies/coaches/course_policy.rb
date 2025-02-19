class Coaches::CoursePolicy < ApplicationPolicy
  def index?
    user.coach? || user.manager?
  end

  def show?
    record.coaches.include?(user) || user.manager?
  end

  def update_enrollments?
    record.coaches.include?(user) || user.manager? || user.coordinator?
  end
end
