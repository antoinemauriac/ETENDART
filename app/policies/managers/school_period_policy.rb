class Managers::SchoolPeriodPolicy < ApplicationPolicy
  def index?
    user.manager?
  end

  def create?
    user.manager? && record.academy.manager == user
  end

  def show?
    user.manager? && record.academy.manager == user
  end

  def destroy?
    user.manager? && record.academy.manager == user
  end

  def statistics?
    user.manager? && record.academy.manager == user
  end

  def export_bilan_csv?
    user.manager? && record.academy.manager == user
  end

  class Scope < Scope
    def resolve
      # scope.where(manager_id: user.id)
    end
  end
end
