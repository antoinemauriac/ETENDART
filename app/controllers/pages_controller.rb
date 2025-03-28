class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    @academies = Academy.includes(:school_periods).new_format
                       .sort_by { |academy| academy.next_school_periods.any? ? 0 : 1 }
  end


  # def dashboard
  #   @user = current_user
  # end
end
