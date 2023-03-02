class Managers::StudentPolicy < ApplicationPolicy
  def index?
    user.manager?
  end

  def show?
    user.manager? && record.academies.any? { |academy| academy.manager == user }
  end

  def create?
    user.manager?
  end

  def import?
    user.manager?
  end
end
