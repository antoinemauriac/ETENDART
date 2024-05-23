class Managers::CampPolicy < ApplicationPolicy

  def create?
    authorized?
  end

  def show?
    authorized?
  end

  def destroy?
    authorized?
  end

  def export_students_csv?
    authorized?
  end

  def export_banished_students_csv?
    authorized?
  end

  private

  def authorized?
    academy = record.school_period.academy
    (user.manager? && academy.manager == user) || (user.coordinator? && academy.coordinator == user)
  end
end
