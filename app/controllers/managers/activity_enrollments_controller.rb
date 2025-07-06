class Managers::ActivityEnrollmentsController < ApplicationController
  def destroy
    @activity_enrollment = ActivityEnrollment.find(params[:id])
    authorize([:managers, @activity_enrollment])

    student = @activity_enrollment.student
    activity = @activity_enrollment.activity

    @next_course_enrollments = student.course_enrollments.where(course: activity.next_courses)
    @next_course_enrollment_ids = @next_course_enrollments.pluck(:id)
    @activity_enrollment.destroy

    if activity.camp
      manage_membership(student, activity.camp, nil)

      if params[:redirect_to] == 'student'
        flash.now[:notice] = "Élève retiré de l'activité."
        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to managers_student_path(student), notice: "Élève retiré de l'activité." }
        end
      else
        redirect_to managers_activity_path(activity), notice: "Élève retiré de l'activité."
      end

    elsif activity.annual_program
      manage_membership(student, nil, activity.annual_program)

      if params[:redirect_to] == 'student'
        flash.now[:notice] = "Élève retiré de l'activité."
        respond_to do |format|
          format.turbo_stream
          format.html { redirect_to managers_student_path(student), notice: "Élève retiré de l'activité." }
        end
      else
        redirect_to show_for_annual_managers_activity_path(activity), notice: "Élève retiré de l'activité."
      end
    end
  end

  private

  def manage_membership(student, camp, annual_program)
    if camp
      start_year = camp.starts_at.month >= 9 ? camp.starts_at.year : camp.starts_at.year - 1
    elsif annual_program
      start_year = annual_program.starts_at.year
    end
    courses_during_civil_year = student.courses.where('starts_at >= ? AND starts_at <= ?', Date.new(start_year, 4, 7), Date.new(start_year + 1, 8, 31))
    membership = student.memberships.find_by(start_year: start_year)
    if courses_during_civil_year.empty? && membership && !membership.paid
      membership&.destroy
    end
  end
end
