class Managers::FinancePolicy < ApplicationPolicy

  def index?
    user.manager?
  end
end
