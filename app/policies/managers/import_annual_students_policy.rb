class Managers::ImportAnnualStudentsPolicy < ApplicationPolicy
  def import?
    user.manager?
  end
end
