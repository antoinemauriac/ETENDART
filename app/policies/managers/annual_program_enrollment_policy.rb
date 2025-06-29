class Managers::AnnualProgramEnrollmentPolicy < ApplicationPolicy
  def update?
    user.manager? || user.coordinator? || user.coach?
  end

  def destroy?
    user.manager? || user.coordinator? || user.coach?
  end
end
