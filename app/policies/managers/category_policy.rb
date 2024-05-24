class Managers::CategoryPolicy < ApplicationPolicy

  def index?
    user.manager? || user.coordinator?
  end

  def create?
    user.manager? || user.coordinator?
  end

  def update?
    user.manager? || user.coordinator?
  end

  def destroy?
    user.manager? || user.coordinator?
  end

  def category_coaches?
    user.manager? || user.coordinator?
  end


end
