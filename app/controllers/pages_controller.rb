class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @academies = Academy.includes(:school_periods).reject { |academy| academy.next_school_periods.empty? }
  end


  # def dashboard
  #   @user = current_user
  # end
end
