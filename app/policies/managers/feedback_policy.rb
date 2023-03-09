class Managers::FeedbackPolicy < ApplicationPolicy
 def create?
   user.manager?
 end
end
