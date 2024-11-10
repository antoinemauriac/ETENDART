class Managers::CampEnrollmentsController < ApplicationController
  def destroy
    camp_enrollment = CampEnrollment.find(params[:id])
    authorize([:managers, camp_enrollment])

    student = camp_enrollment.student
    camp = camp_enrollment.camp
    school_period = camp.school_period

    student.activity_enrollments.where(activity: camp.activities).destroy_all
    student.course_enrollments.where(course: camp.courses).destroy_all
    if camp_enrollment.destroy
      camp_enrollments = student.camp_enrollments.where(camp: school_period.camps)
      if camp_enrollments.empty?
        student.school_period_enrollments.find_by(school_period: school_period).destroy
      end
      flash[:notice] = "Élève retiré du camp"
    else
      flash[:alert] = "Erreur lors de la suppression"
    end
    redirect_to managers_camp_path(camp)
  end
end
