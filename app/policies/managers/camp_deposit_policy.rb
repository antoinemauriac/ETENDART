class Managers::CampDepositPolicy < ApplicationPolicy
  def create?
    user.manager? || user.coordinator?
  end
end
