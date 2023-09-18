class Managers::ActivityEnrollmentPolicy < ApplicationPolicy
  def destroy?
    if record.camp
      user.manager? && record.activity.camp.school_period.academy.manager == user
    else
      user.manager? && record.activity.annual_program.academy.manager == user
    end
  end
end
