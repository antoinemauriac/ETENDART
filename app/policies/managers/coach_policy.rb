class Managers::CoachPolicy < ApplicationPolicy

  def index?
    user.manager? || user.coordinator?
  end

  def show?
    user.manager? || user.coordinator?
  end

  def create?
    user.manager? || user.coordinator?
  end

  def update?
    user.manager? || user.coordinator?
  end

  def update_infos?
    user.manager? || user.coordinator?
  end

  class Scope < Scope
    def resolve
    end
  end

end
