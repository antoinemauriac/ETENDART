class Managers::SchoolPeriodPolicy < ApplicationPolicy
  def create?
    user.manager? && record.academy.manager == user
  end

  def show?
    user.manager? && record.academy.manager == user
  end

  class Scope < Scope
    def resolve
      # scope.where(manager_id: user.id)
    end
  end
end
