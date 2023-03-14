class Coaches::StudentProfilePolicy < ApplicationPolicy
  def show?
    user.coach? || user.manager?
  end

  def index?
    user.coach? || user.manager?
  end
end
