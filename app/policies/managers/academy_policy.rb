class Managers::AcademyPolicy < ApplicationPolicy
  # def index?
  #   user.manager?
  # end

  def show?
    authorized?
  end

  def export_absent_students_csv?
    authorized?
  end

  def export_week_absent_students_csv?
    authorized?
  end

  def today_absent_students?
    authorized?
  end

  def week_absent_students?
    authorized?
  end

  private

  def authorized?
    (user.manager? && record.manager == user) || (user.coordinator? && record.coordinator == user)
  end
end
