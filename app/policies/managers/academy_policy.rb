class Managers::AcademyPolicy < ApplicationPolicy
  def index?
    user.manager?
  end

  def show?
    user.manager? && record.manager == user
  end

  def export_absent_students_csv?
    user.manager? && record.manager == user
  end

  def export_week_absent_students_csv?
    user.manager? && record.manager == user
  end

  def today_absent_students?
    user.manager? && record.manager == user
  end

  def week_absent_students?
    user.manager? && record.manager == user
  end

  class Scope < Scope
    def resolve
      scope.where(manager_id: user.id)
    end
  end
end
