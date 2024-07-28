class Managers::MembershipDepositPolicy < ApplicationPolicy

  def index?
    user.manager? || user.coordinator? || user.admin?
  end

  def create?
    user.manager? || user.coordinator?
  end
end
