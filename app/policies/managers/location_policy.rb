class Managers::LocationPolicy < ApplicationPolicy
  def index?
    user.manager? || user.coordinator?
  end

  def create?
    user.manager? || user.coordinator?
  end

  def update?
    user.manager? || user.coordinator?
  end
end
