class Coaches::CoursesController < ApplicationController

  before_action :course, only: %i[show]

  def index
    @coach = current_user
    @next_courses = @coach.next_courses.includes(:activity)
    @past_courses = @coach.past_courses.includes(:activity)
    skip_policy_scope
    authorize([:coaches, @camps], policy_class: Coaches::CoursePolicy)
  end

  def show
    authorize([:coaches, @course], policy_class: Coaches::CoursePolicy)
    @enrollments = course.course_enrollments
                         .includes(student: [:photo_attachment, :camp_enrollments])
                         .joins(:student)
                         .order('students.last_name ASC')
    @academy = course.academy
    @camp = course.camp
    @school_period = course.school_period
    @category = course.category
    @activity = course.activity
    @start_year = course.starts_at.month >= 9 ? course.starts_at.year : course.starts_at.year - 1
    @banished_students = @activity.banished_students.where.not(id: @enrollments.pluck(:student_id)).order(last_name: :asc)
    @present_students_count = @course.present_students_count
    @missing_students_count = @course.missing_students_count
  end

  private

  def course
    @course ||= Course.find(params[:id])
  end
end
