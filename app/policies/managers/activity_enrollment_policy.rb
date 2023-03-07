class Managers::ActivityEnrollmentPolicy < ApplicationPolicy
  def destroy?
    user.manager? && record.activity.camp.school_period.academy.manager == user
  end
end
