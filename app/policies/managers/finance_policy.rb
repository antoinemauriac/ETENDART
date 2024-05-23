class Managers::FinancePolicy < ApplicationPolicy

  def membership_finances_overview?
    user.manager? || user.coordinator?
  end

  def camp_finances_overview?
    user.manager? || user.coordinator?
  end

  def export_members_csv?
    user.manager? || user.coordinator?
  end
end
