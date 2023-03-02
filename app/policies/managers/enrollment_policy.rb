class Managers::EnrollmentPolicy < ApplicationPolicy
  def create?
    user.manager?
  end

  def update_school_periods?
    user.manager?
  end

  def update_camps?
    user.manager?
  end

  def update_activities?
    user.manager?
  end
end
