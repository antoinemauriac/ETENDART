class Managers::AcademyPolicy < ApplicationPolicy
  def index?
    user.manager?
  end

  def show?
    user.manager? && record.manager == user
  end

  class Scope < Scope
    def resolve
      scope.where(manager_id: user.id)
    end
  end
end
