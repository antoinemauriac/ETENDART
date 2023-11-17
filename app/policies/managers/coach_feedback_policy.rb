class Managers::CoachFeedbackPolicy < ApplicationPolicy
  def create?
    user.manager?
  end

  def destroy?
    user.manager? && record.manager == user
  end
end
