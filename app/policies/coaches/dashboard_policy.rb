class Coaches::DashboardPolicy < ApplicationPolicy
  def index?
    user.coach? || user.manager?
  end
end
