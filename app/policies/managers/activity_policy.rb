class Managers::ActivityPolicy < ApplicationPolicy

  def new?
    user.manager? || user.coordinator?
  end

  def create?
    authorized?
  end

  def show?
    authorized?
  end

  def new_for_annual?
    user.manager? || user.coordinator?
  end

  def create_for_annual?
    authorized?
  end

  def show_for_annual?
    authorized?
  end

  def all_annual_courses?
    authorized?
  end

  def destroy?
    authorized?
  end

  def update?
    authorized?
  end

  def export_activity_students?
    authorized?
  end

  private

  def authorized?
    academy = find_academy
    (user.manager? && academy.manager == user) || (user.coordinator? && academy.coordinator == user)
  end

  def find_academy
    if record.camp
      record.camp.school_period.academy
    else
      record.annual_program.academy
    end
  end
end
