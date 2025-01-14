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

    @parent = current_user
    @children = @parent.children
    @activity_enrollment = ActivityEnrollment.new
  end
end

# create_table "activity_enrollments", force: :cascade do |t|
#   t.bigint "student_id", null: false
#   t.bigint "activity_id", null: false
#   t.datetime "created_at", null: false
#   t.datetime "updated_at", null: false
#   t.boolean "present", default: false
#   t.index ["activity_id"], name: "index_activity_enrollments_on_activity_id"
#   t.index ["student_id"], name: "index_activity_enrollments_on_student_id"
# end
