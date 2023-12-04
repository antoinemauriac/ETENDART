class Managers::FeedbackPolicy < ApplicationPolicy
 def create?
   user.manager?
 end

  def destroy?
    user.manager? && record.coach == user
  end
end
