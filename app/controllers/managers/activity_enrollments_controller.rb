class Managers::ActivityEnrollmentsController < ApplicationController
  def destroy
    @activity_enrollment = ActivityEnrollment.find(params[:id])
    authorize([:managers, @activity_enrollment])
    # @activity_enrollment.destroy
    student = @activity_enrollment.student
    activity = @activity_enrollment.activity
    camp = activity.camp
    school_period = camp.school_period

    #détruire les course_enrollments associés
    student.course_enrollments.where(course: activity.next_courses).destroy_all

    course_enrollments = student.course_enrollments.where(course: activity.courses)
    if course_enrollments.empty?
      student.activity_enrollments.where(activity: activity).destroy_all
    end

    activities = student.activities.where(camp: camp)
    if activities.empty?
      student.camp_enrollments.where(camp: camp).destroy_all
    end

    camp_enrollments = student.camp_enrollments.where(camp: school_period.camps)
    if camp_enrollments.empty?
      student.school_period_enrollments.where(school_period: school_period).destroy_all
    end

    respond_to do |format|
      format.html do
        if params[:redirect_to] == 'student'
          redirect_to managers_student_path(@activity_enrollment.student), notice: "Élève retiré de l'activité."
        else
          redirect_to managers_activity_path(@activity_enrollment.activity), notice: "Élève retiré de l'activité."
        end
      end
      format.json { head :no_content }
    end
  end
end
