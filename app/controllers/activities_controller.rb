class ActivitiesController < ApplicationController
  def show
    @activity = Activity.find(params[:id])
    @academy = @activity.academy
    @camp = @activity.camp
    @school_period = @camp.school_period
    # @students = @activity.students_with_next_activity_enrollments.sort_by(&:last_name)
    @students = @activity.students.sort_by(&:last_name)
    authorize(@activity)
    @courses = @activity.courses.sort_by(&:starts_at)
    category = @activity.category
    @coach = @activity.coach
    @coaches = category.coaches.joins(:coach_academies).where(coach_academies: { academy_id: @academy.id })
    @start_year = @camp.starts_at.month >= 9 ? @camp.starts_at.year : @camp.starts_at.year - 1
  end
end
