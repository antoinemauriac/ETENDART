class Managers::StudentPolicy < ApplicationPolicy
  def index?
    user.manager?
  end

  def show?
    user.manager? && record.academies.any? { |academy| academy.manager == user }
  end

  def create?
    user.manager?
  end

  def update?
    user.manager? && record.academies.any? { |academy| academy.manager == user }
  end

  def import?
    user.manager?
  end

  def import_annual_students?
    user.manager?
  end

  def update_photo?
    user.manager? || user.coach?
  end

  def export_students_csv?
    user.manager?
  end
end
