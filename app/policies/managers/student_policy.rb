class Managers::StudentPolicy < ApplicationPolicy
  def index_for_admin?
    user.admin?
  end

  def index?
    user.manager? || user.coordinator?
  end

  def show?
    user.manager? || user.coordinator?
  end

  def current_activities?
    user.manager? || user.coordinator?
  end

  def past_activities?
    user.manager? || user.coordinator?
  end

  def create?
    user.manager?
  end

  def update?
    user.manager? || user.coordinator?
  end

  def update_photo?
    user.manager? || user.coach? || user.coordinator?
  end

  def export_students_csv?
    user.manager? || user.coordinator? || user.admin?
  end
end
