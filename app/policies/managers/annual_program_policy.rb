class Managers::AnnualProgramPolicy < ApplicationPolicy
  def index?
    academy = record.first.academy
    (user.manager? && academy.manager == user) || (user.coordinator? && academy.coordinator == user)
  end

  def show?
    authorized?
  end

  def new?
    authorized?
  end

  def create?
    authorized?
  end

  def destroy?
    authorized?
  end

  def export_past_enrollments?
    authorized?
  end

  def export_annual_students?
    authorized?
  end

  def statistics?
    authorized?
  end

  private

  def authorized?
    academy = record.academy
    (user.manager? && academy.manager == user) || (user.coordinator? && academy.coordinator == user)
  end
end
