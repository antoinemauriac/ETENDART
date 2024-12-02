class Managers::ActivityEnrollmentPolicy < ApplicationPolicy
  def destroy?
    if record.camp
      academy = record.camp.school_period.academy
      (user.manager? && academy.manager == user) || (user.coordinator? == user && academy.coordinator == user)
    else
      academy = record.activity.annual_program.academy
      (user.manager? && academy.manager == user) || (user.coordinator? == user && academy.coordinator == user)
    end
  end
end
