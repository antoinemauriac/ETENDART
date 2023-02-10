class Managers::CoursesController < ApplicationController

  def index
    @courses = Course.where(manager: current_user).where('ends_at >= ?', 12.hours.ago).sort_by(&:starts_at)
  end
end
