class Parents::AnnualProgramEnrollmentPolicy < ApplicationPolicy
  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end

  def new?
    user.parent?
  end

  def create?
    user.parent?
  end

  def filter_annual_programs?
    user.parent?
  end
end
