class Managers::MembershipPolicy < ApplicationPolicy
  def update?
    user.manager? || user.coach? || user.coordinator?
  end
end
