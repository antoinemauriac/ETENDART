class Managers::LocationPolicy < ApplicationPolicy
  def create?
    user.manager?
  end
end
