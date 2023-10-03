class Managers::ActivityPolicy < ApplicationPolicy

  def new?
    user.manager?
  end

  def create?
    user.manager? && record.camp.school_period.academy.manager == user
  end

  def show?
    user.manager? && record.camp.school_period.academy.manager == user
  end

  def destroy?
    if record.camp
      user.manager? && record.camp.school_period.academy.manager == user
    else
      user.manager? && record.annual_program.academy.manager == user
    end
  end

  def update?
    if record.camp
      user.manager? && record.camp.school_period.academy.manager == user
    else
      user.manager? && record.annual_program.academy.manager == user
    end
  end

  def new_for_annual?
    user.manager?
  end

  def create_for_annual?
    user.manager? && record.annual_program.academy.manager == user
  end

  def show_for_annual?
    user.manager? && record.annual_program.academy.manager == user
  end

  def all_annual_courses?
    user.manager? && record.annual_program.academy.manager == user
  end

  def export_activity_students?
    if record.camp
      user.manager? && record.camp.school_period.academy.manager == user
    else
      user.manager? && record.annual_program.academy.manager == user
    end
  end

  class Scope < Scope
    def resolve

    end
  end
end
