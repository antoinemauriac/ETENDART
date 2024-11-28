class Managers::OldCampDepositPolicy < ApplicationPolicy
  def create?
    user.manager? || user.coordinator?
  end
end
