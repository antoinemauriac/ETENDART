class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @academies = Academy.includes(:school_periods)

  end

  # def dashboard
  #   @user = current_user
  # end
end
