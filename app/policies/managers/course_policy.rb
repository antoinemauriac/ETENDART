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
    record.academy.manager == user || record.all_coaches.include?(user)
  end

  def unban_student?
    user.manager?
  end
end
