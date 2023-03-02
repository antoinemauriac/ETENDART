class Managers::CoachPolicy < ApplicationPolicy

  def index?
    user.manager?
  end

  def show?
    user.manager?
  end

  def create?
    user.manager?
  end

  def update?
    user.manager?
  end

  class Scope < Scope
    def resolve
    end
  end

end
