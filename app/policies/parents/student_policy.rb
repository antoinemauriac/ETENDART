class Parents::StudentPolicy < ApplicationPolicy
  # NOTE: Up to Pundit v2.3.1, the inheritance was declared as
  # `Scope < Scope` rather than `Scope < ApplicationPolicy::Scope`.
  # In most cases the behavior will be identical, but if updating existing
  # code, beware of possible changes to the ancestors:
  # https://gist.github.com/Burgestrand/4b4bc22f31c8a95c425fc0e30d7ef1f5
  class Scope < ApplicationPolicy::Scope
    # NOTE: Be explicit about which records you allow access to!
    def resolve
      if user.admin?
        scope.all
      elsif user.parent?
        scope.where(user_id: user.id)
      else
        scope.none
      end
    end
  end

  def index?
    user.present? && user.parent?
  end

  def assign_children?
    user.present? && user.parent?
  end

  def new?
    user.present? && user.parent?
  end

  def create?
    new?
  end

  def show?
    user.present? && user.parent?
  end

  def edit?
    show?
  end

  def update?
    edit?
  end

end
