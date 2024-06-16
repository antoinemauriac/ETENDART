class Managers::ImportStudentPolicy < ApplicationPolicy
  def import?
    academy = record.academy
    (user.manager? && academy.manager == user) || (user.coordinator? && academy.coordinator == user)
  end

  def import_without_camp?
    (user.manager? && record.manager == user) || (user.coordinator? && record.coordinator == user)
  end
end
