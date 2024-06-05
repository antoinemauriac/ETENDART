class Managers::ActivityPolicy < ApplicationPolicy

  def new?
    user.manager? || user.coordinator?
  end

  def create?
    authorized_for_camp?
  end

  def show?
    authorized_for_camp?
  end

  def new_for_annual?
    authorized_for_annual?
  end

  def create_for_annual?
    authorized_for_annual?
  end

  def show_for_annual?
    authorized_for_annual?
  end

  def all_annual_courses?
    authorized_for_annual?
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
    if record.camp
      academy = record.camp.school_period.academy
      (user.manager? && academy.manager == user) || (user.coordinator? && academy.coordinator == user)
    else
      academy = record.annual_program.academy
      (user.manager? && academy.manager == user) || (user.coordinator? && academy.coordinator == user)
    end
  end

  def authorized_for_annual?
    academy = record.annual_program.academy
    (user.manager? && academy.manager == user) || (user.coordinator? && academy.coordinator == user)
  end

  def authorized_for_camp?
    academy = record.camp.school_period.academy
    (user.manager? && academy.manager == user) || (user.coordinator? && academy.coordinator == user)
  end
end
