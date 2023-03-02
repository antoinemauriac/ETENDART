class Managers::CategoryPolicy < ApplicationPolicy

  def index?
    user.manager?
  end

  def create?
    user.manager?
  end

  def update?
    user.manager?
  end

  def destroy?
    user.manager?
  end

  def category_coaches?
    user.manager?
  end

  class Scope < Scope
    def resolve

    end
  end
end
