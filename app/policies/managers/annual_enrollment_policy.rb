class Managers::AnnualEnrollmentPolicy < ApplicationPolicy
  def create?
    user.manager?
  end

  def update_annual_programs?
    user.manager?
  end

  def update_activities?
    user.manager?
  end
end
