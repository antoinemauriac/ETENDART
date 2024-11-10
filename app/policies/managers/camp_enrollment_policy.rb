class Managers::CampEnrollmentPolicy < ApplicationPolicy
  def destroy?
    academy = record.camp.school_period.academy
    (user.manager? && academy.manager == user) || (user.coordinator? && academy.coordinator == user)
  end
end
