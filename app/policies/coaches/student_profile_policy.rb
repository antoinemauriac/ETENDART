class Coaches::StudentProfilePolicy < ApplicationPolicy
  def show?
    user.coach? || user.manager? || user.coordinator?
  end

  def index?
    user.coach? || user.manager? || user.coordinator?
  end
end
