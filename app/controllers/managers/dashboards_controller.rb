class Managers::DashboardsController < ApplicationController
  def index
    @academies = current_user.academies_as_manager
    skip_policy_scope
    authorize([:managers, @academies], policy_class: Managers::DashboardPolicy)
  end
end
