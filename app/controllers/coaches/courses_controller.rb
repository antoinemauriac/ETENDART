class Coaches::CoursesController < ApplicationController

  before_action :course, only: %i[show]

  def index
    @coach = current_user
    @next_courses = @coach.next_courses
    @past_courses = @coach.past_courses
    skip_policy_scope
    authorize([:coaches, @camps], policy_class: Coaches::CoursePolicy)
  end

  def show
    @start_year = Date.current.month >= 9 ? Date.current.year : Date.current.year - 1
    @enrollments = course.course_enrollments.joins(:student).order(last_name: :asc)
    @academy = course.academy
    # @school_periods = @academy.school_periods
    @camp = course.camp
    @school_period = course.school_period
    @category = course.category
    @activity = course.activity
    @banished_students = @activity.banished_students.where.not(id: @enrollments.pluck(:student_id)).order(last_name: :asc)
    authorize([:coaches, @course], policy_class: Coaches::CoursePolicy)
  end

  private

  def course
    @course ||= Course.find(params[:id])
  end
end
