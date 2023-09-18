class Managers::AnnualProgramPolicy < ApplicationPolicy
  def index?
    user.manager?
  end

  def show?
    user.manager? && record.academy.manager == user
  end

  def new?
    user.manager? && record.academy.manager == user
  end

  def create?
    user.manager? && record.academy.manager == user
  end

  def destroy?
    user.manager? && record.academy.manager == user
  end
end
