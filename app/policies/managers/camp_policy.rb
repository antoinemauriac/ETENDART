class Managers::CampPolicy < ApplicationPolicy
  def create?
    user.manager? && record.school_period.academy.manager == user
  end

  def show?
    user.manager? && record.school_period.academy.manager == user
  end

  def destroy?
    user.manager? && record.school_period.academy.manager == user
  end

  class Scope < Scope
    def resolve

    end
  end
end
