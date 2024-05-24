class Managers::CoursePolicy < ApplicationPolicy

  def show?
    academy = record.academy
    (user.manager? && academy.manager == user) || (user.coordinator? && academy.coordinator == user)
  end

  def update?
    academy = record.academy
    (user.manager? && academy.manager == user) || (user.coordinator? && academy.coordinator == user)
  end

  def destroy?
    academy = record.academy
    (user.manager? && academy.manager == user) || (user.coordinator? && academy.coordinator == user)
  end

  def update_enrollments?
    record.academy.manager == user || record.academy.coordinator == user || record.coaches.include?(user)
  end

  def unban_student?
    user.manager? || user.coordinator?
  end
end
