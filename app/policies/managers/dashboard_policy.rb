class Managers::DashboardPolicy < ApplicationPolicy
  def index?
    user.manager?
  end
end
