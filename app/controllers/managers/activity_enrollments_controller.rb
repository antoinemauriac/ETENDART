class Managers::ActivityEnrollmentsController < ApplicationController
  def destroy
    activity_enrollment = ActivityEnrollment.find(params[:id])
    authorize([:managers, activity_enrollment])

    student = activity_enrollment.student
    activity = activity_enrollment.activity
    camp_enrollment = student.camp_enrollments.find_by(camp: activity.camp)

    activity_enrollment.destroy
    student.course_enrollments.where(course: activity.next_courses).destroy_all

    past_course_enrollments = student.course_enrollments.joins(:course).where(course: activity.courses).where('courses.ends_at < ?', Time.current)
    if past_course_enrollments.attended.count.zero?
      past_course_enrollments.destroy_all
    end

    if activity.camp
      camp = activity.camp
      school_period = camp.school_period

      student_camp_courses = student.courses.joins(:activity).where("activities.camp_id = ?", camp.id)
      if student_camp_courses.empty?
        camp_enrollment.destroy
      end

      camp_enrollments = student.camp_enrollments.where(camp: school_period.camps)
      if camp_enrollments.empty?
        student.school_period_enrollments.find_by(school_period: school_period).destroy
      end

      start_year = camp.starts_at.month >= 9 ? camp.starts_at.year : camp.starts_at.year - 1
      courses_during_civil_year = student.courses.where('starts_at >= ? AND starts_at <= ?', Date.new(start_year, 4, 1), Date.new(start_year + 1, 8, 31))
      membership = student.memberships.find_by(start_year: start_year)
      if courses_during_civil_year.empty? && membership && membership.status == false
        membership&.destroy
      end

      if params[:redirect_to] == 'student'
        redirect_to managers_student_path(student), notice: "Élève retiré de l'activité."
      else
        redirect_to managers_activity_path(activity), notice: "Élève retiré de l'activité."
      end

    elsif activity.annual_program
      annual_program = activity.annual_program
      # activities = student.activities.where(annual_program: annual_program)
      student_annual_courses = student.courses.joins(:activity).where("activities.annual_program_id = ?", annual_program.id)

      if student_annual_courses.empty?
        student.annual_program_enrollments.find_by(annual_program: annual_program).destroy
      end

      if params[:redirect_to] == 'student'
        redirect_to managers_student_path(student), notice: "Élève retiré de l'activité."
      else
        redirect_to show_for_annual_managers_activity_path(activity), notice: "Élève retiré de l'activité."
      end
    end
  end
end
