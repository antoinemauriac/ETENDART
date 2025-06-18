class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @school_periods = SchoolPeriod.with_future_camps
    @academies = Academy.new_format.joins(:school_periods)
                        .where(school_periods: { id: @school_periods.pluck(:id) })
                        .distinct
  end
end
