class Coaches::DashboardsController < ApplicationController
  def index
    @academies = current_user.academies_as_coach
    skip_policy_scope
    authorize([:coaches, @academies], policy_class: Coaches::DashboardPolicy)
  end
end
