class Managers::ImportAnnualStudentsPolicy < ApplicationPolicy
  def import?
    user.manager? || user.coordinator?
  end
end
