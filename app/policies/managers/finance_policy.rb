class Managers::FinancePolicy < ApplicationPolicy

  def membership_finances_overview?
    user.manager? || user.coordinator? || user.admin?
  end

  def index?
    user.manager? || user.coordinator? || user.admin?
  end

  def export_members_csv?
    user.manager? || user.coordinator? || user.admin?
  end

  def show?
    user.manager? || user.coordinator? || user.admin?
  end

end
