class Managers::DashboardsController < ApplicationController
  def index
    @academies = current_user.academies.includes(image_attachment: :blob)
    skip_policy_scope
    authorize([:managers, @academies], policy_class: Managers::DashboardPolicy)
  end

  def index_for_admin
    @academies = Academy.all
    skip_policy_scope
    authorize([:managers, @academies], policy_class: Managers::DashboardPolicy)
  end
end
