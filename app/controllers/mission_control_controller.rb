class MissionControlController < ApplicationController
  before_action :authorize_mission_control_access
  around_action :use_english_locale

  private

  def use_english_locale(&action)
    I18n.with_locale(:en, &action)
  end

  def authorize_mission_control_access
    skip_policy_scope
    authorize([:mission_control], :access?, policy_class: MissionControlPolicy)
  end
end
