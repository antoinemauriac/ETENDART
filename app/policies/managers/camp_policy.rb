class Managers::CampPolicy < ApplicationPolicy

  def create?
    user.manager?
  end

  def show?
    authorized?
  end

  def activities?
    authorized?
  end

  def students?
    authorized?
  end

  def payment_details?
    authorized?
  end

  def destroy?
    user.manager?
  end

  def update?
    user.manager?
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
