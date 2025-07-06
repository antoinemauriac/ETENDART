class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @school_periods = SchoolPeriod.with_future_camps
    @academies = Academy.new_format.joins(:school_periods)
                        .where(school_periods: { id: @school_periods.pluck(:id) })
                        .distinct

    # Ajouter les académies avec des programmes annuels à venir
    @annual_academies = Academy.new_format.joins(:annual_programs)
                               .where(annual_programs: { ends_at: Date.today.. })
                               .where(annual_programs: { new: true })
                               .distinct
  end
end
