class Managers::AnnualEnrollmentPolicy < ApplicationPolicy
  def create?
    user.manager? || user.coordinator?
  end

  def update_annual_programs?
    user.manager? || user.coordinator?
  end

  def update_activities?
    user.manager? || user.coordinator?
  end
end
