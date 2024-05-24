class Managers::CoachFeedbackPolicy < ApplicationPolicy
  def create?
    user.manager? || user.coordinator?
  end

  def destroy?
    (user.manager? && record.manager == user) || (user.coordinator? && record.manager == user)
  end
end
