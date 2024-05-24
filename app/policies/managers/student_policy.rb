class Managers::StudentPolicy < ApplicationPolicy
  def index_for_admin?
    user.admin?
  end

  def index?
    user.manager? || user.coordinator?
  end

  def show?
    (user.manager? && record.academies.any? { |academy| academy.manager == user }) || (user.coordinator? && record.academies.any? { |academy| academy.coordinator == user })
  end

  def create?
    user.manager? || user.coordinator?
  end

  def update?
    (user.manager? && record.academies.any? { |academy| academy.manager == user }) || (user.coordinator? && record.academies.any? { |academy| academy.coordinator == user })
  end

  def import?
    academy = record.academy
    (user.manager? && academy.manager == user) || (user.coordinator? && academy.coordinator == user)
  end

  def import_annual_students?
    academy = record.academy
    (user.manager? && academy.manager == user) || (user.coordinator? && academy.coordinator == user)
  end

  def update_photo?
    user.manager? || user.coach? || user.coordinator?
  end

  def export_students_csv?
    user.manager? || user.coordinator?
  end
end
