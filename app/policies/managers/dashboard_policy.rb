class Managers::DashboardPolicy < ApplicationPolicy
  def index?
    user.manager? || user.coordinator?
  end

  def index_for_admin?
    user.admin?
  end
end
