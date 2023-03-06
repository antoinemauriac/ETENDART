class Managers::LocationPolicy < ApplicationPolicy
  def index?
    user.manager?
  end

  def create?
    user.manager?
  end
end
