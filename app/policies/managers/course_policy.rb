class Managers::CoursePolicy < ApplicationPolicy
  def index?
    user.manager?
  end

  def show?
    user.manager?
  end

  def create?
    user.manager?
  end

  def edit?
    user.manager?
  end

  def update?
    user.manager?
  end

  def destroy?
    user.manager?
  end

  def update_enrollments?
    user.manager?
  end
end
