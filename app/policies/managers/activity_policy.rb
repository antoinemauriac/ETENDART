class Managers::ActivityPolicy < ApplicationPolicy

  def new?
    user.manager?
  end

  def create?
    user.manager? && record.camp.school_period.academy.manager == user
  end

  def show?
    user.manager? && record.camp.school_period.academy.manager == user
  end

  def destroy?
    user.manager? && record.camp.school_period.academy.manager == user
  end

  class Scope < Scope
    def resolve

    end
  end
end
