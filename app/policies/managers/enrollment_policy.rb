class Managers::EnrollmentPolicy < ApplicationPolicy
  def create?
    user.manager? || user.coordinator?
  end

  def update_school_periods?
    user.manager? || user.coordinator?
  end

  def update_camps?
    user.manager? || user.coordinator?
  end

  def update_activities?
    user.manager? || user.coordinator?
  end
end
