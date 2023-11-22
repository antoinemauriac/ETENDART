class Managers::ActivityEnrollmentsController < ApplicationController
  def destroy
    activity_enrollment = ActivityEnrollment.find(params[:id])
    authorize([:managers, activity_enrollment])

    student = activity_enrollment.student
    activity = activity_enrollment.activity
    camp_enrollment = student.camp_enrollments.find_by(camp: activity.camp)

    activity_enrollment.destroy
    student.course_enrollments.where(course: activity.next_courses).destroy_all

    # course_enrollments = student.course_enrollments.where(course: activity.courses)
    # if course_enrollments.empty?
    #   student.activity_enrollments.find_by(activity: activity).destroy
    # end

    # activity_enrollment.update(deleted: true) if activity_enrollment.present?

    if params[:origin] == 'camp'
      camp = activity.camp
      school_period = camp.school_period

      student_camp_courses = student.courses.joins(:activity).where("activities.camp_id = ?", camp.id)
      # activities = student.activities.where(camp: camp)
      if student_camp_courses.empty?
        student.camp_enrollments.find_by(camp: camp).destroy
      end

      camp_enrollments = student.camp_enrollments.where(camp: school_period.camps)
      if camp_enrollments.empty?
        student.school_period_enrollments.find_by(school_period: school_period).destroy
      end
    else
      annual_program = activity.annual_program
      activities = student.activities.where(annual_program: annual_program)
      if activities.empty?
        student.annual_program_enrollments.find_by(annual_program: annual_program).destroy
      end
    end

    respond_to do |format|
      format.html do
        if params[:origin] == 'camp'
          if params[:redirect_to] == 'student'
            redirect_to managers_student_path(student), notice: "Élève retiré de l'activité."
          else
            redirect_to managers_activity_path(activity), notice: "Élève retiré de l'activité."
          end
        else
          if params[:redirect_to] == 'student'
            redirect_to managers_student_path(student), notice: "Élève retiré de l'activité."
          else
            redirect_to show_for_annual_managers_activity_path(activity), notice: "Élève retiré de l'activité."
          end
        end
      end
      format.json { head :no_content }
    end
  end
end
