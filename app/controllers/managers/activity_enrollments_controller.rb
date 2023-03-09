class Managers::ActivityEnrollmentsController < ApplicationController
  def destroy
    @activity_enrollment = ActivityEnrollment.find(params[:id])
    authorize([:managers, @activity_enrollment])
    @activity_enrollment.destroy

    #détruire les course_enrollments associés
    @activity_enrollment.student.course_enrollments.where(course: @activity_enrollment.activity.courses).destroy_all
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
