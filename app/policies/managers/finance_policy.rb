class Managers::FinancePolicy < ApplicationPolicy

  def membership_finances_overview?
    user.manager?
  end

  def camp_finances_overview?
    user.manager?
  end

  def export_members_csv?
    user.manager?
  end
end
