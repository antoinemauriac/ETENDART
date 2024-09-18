class MissionControlPolicy < ApplicationPolicy
  def access?
    user.admin?
  end
end
