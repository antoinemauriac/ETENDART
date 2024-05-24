class Managers::FeedbackPolicy < ApplicationPolicy
 def create?
   user.manager? || user.coordinator?
 end

  def destroy?
    (user.manager? && record.coach == user) || (user.coordinator? && record.coach == user)
  end
end
