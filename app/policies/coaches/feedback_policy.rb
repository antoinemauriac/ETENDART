class Coaches::FeedbackPolicy < ApplicationPolicy
  def create?
    user.coach? || user.manager?
  end
end
