class Coaches::CoursesController < ApplicationController

  before_action :course, only: %i[show]

  def index
    @coach = current_user
    @current_time = Time.current
    @next_courses = @coach.next_courses
    @past_courses = @coach.past_courses
    skip_policy_scope
    authorize([:coaches, @camps], policy_class: Coaches::CoursePolicy)
  end

  def show
    @enrollments = course.course_enrollments.joins(:student).order(last_name: :asc)
    @academy = course.academy
    @school_period = course.school_period
    @category = course.category
    @activity = course.activity
    @banished_students = @activity.banished_students.where.not(id: @enrollments.pluck(:student_id))
    authorize([:coaches, @course], policy_class: Coaches::CoursePolicy)
  end

  private

  def course
    @course ||= Course.find(params[:id])
  end
end
