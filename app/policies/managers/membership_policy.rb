class Managers::MembershipPolicy < ApplicationPolicy
  def update?
    user.manager? || user.coach?
  end
end
