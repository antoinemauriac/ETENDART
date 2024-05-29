class Managers::MembershipPolicy < ApplicationPolicy
  def update?
    user.manager? || user.coach? || user.coordinator?
  end

  def create?
    user.manager? || user.coordinator?
  end
end
