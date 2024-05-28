class Managers::SchoolPeriodPolicy < ApplicationPolicy
  def index?
    academy = record.first.academy
    (user.manager? && academy.manager == user) || (user.coordinator? && academy.coordinator == user)
  end

  def create?
    authorized?
  end

  def show?
    authorized?
  end

  def destroy?
    authorized?
  end

  def statistics?
    authorized?
  end

  def export_bilan_csv?
    authorized?
  end

  def index_for_admin?
    user.admin?
  end

  private

  def authorized?
    academy = record.academy
    (user.manager? && academy.manager == user) || (user.coordinator? && academy.coordinator == user) || user.admin?
  end
end
