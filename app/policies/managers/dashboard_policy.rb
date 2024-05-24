class Managers::DashboardPolicy < ApplicationPolicy
  def index?
    user.manager? || user.coordinator?
  end
end
