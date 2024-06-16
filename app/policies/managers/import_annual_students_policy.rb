class Managers::ImportAnnualStudentsPolicy < ApplicationPolicy
  def import?
    academy = record.academy
    (user.manager? && academy.manager == user) || (user.coordinator? && academy.coordinator == user)
  end
end
