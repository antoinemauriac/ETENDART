class Managers::CoursesController < ApplicationController
  before_action :course, only: %i[edit show update destroy]

  def index
    @courses = current_user.courses_as_manager.sort_by(&:starts_at)
    skip_policy_scope
    authorize([:managers, @courses], policy_class: Managers::CoursePolicy)
  end

  def show
    @enrollments = course.course_enrollments.joins(:student).order(last_name: :asc)
    @academy = course.academy
    @activity = course.activity
    @school_period = course.school_period if course.school_period
    @camp = course.camp if course.camp
    @annual_program = @activity.annual_program if @activity.annual_program
    @category = course.category
    @activity = course.activity
    @banished_students = @activity.banished_students.where.not(id: @enrollments.pluck(:student_id)).order(last_name: :asc)
    authorize([:managers, @course], policy_class: Managers::CoursePolicy)
  end

  def edit
    authorize([:managers, @course], policy_class: Managers::CoursePolicy)
  end

  def update
    authorize([:managers, @course], policy_class: Managers::CoursePolicy)
    if course.update(course_params)
      if params[:redirect_to] == "camp"
        redirect_to managers_activity_path(course.activity), notice: "Cours mis à jour"
      else
        redirect_to show_for_annual_managers_activity_path(course.activity), notice: "Cours mis à jour"
      end
    else
      flash[:alert] = "L'heure de début doit être avant l'heure de fin"
      if params[:redirect_to] == "camp"
        redirect_to managers_activity_path(course.activity)
      else
        redirect_to show_for_annual_managers_activity_path(course.activity), notice: "Cours mis à jour"
      end
    end
  end

  def destroy
    authorize([:managers, @course], policy_class: Managers::CoursePolicy)
    course.destroy
    if params[:redirect_to] == "camp"
      redirect_to managers_activity_path(course.activity), notice: "Cours supprimé"
    else
      redirect_to show_for_annual_managers_activity_path(course.activity), notice: "Cours supprimé"
    end
  end

  def update_enrollments
    course = Course.find(params[:id])
    activity = course.activity
    camp = activity.camp if activity.camp
    school_period = camp.school_period if camp

    enrollments_params = permitted_enrollments_params.to_h
    authorize([:managers, course], policy_class: Managers::CoursePolicy)

    if enrollments_params.present?
      enrollments_params.each do |enrollment_id, enrollment_params|
        enrollment = CourseEnrollment.find(enrollment_id.to_i)
        enrollment.present = enrollment_params[:present].to_i
        if enrollment.changes.present?
          enrollments_params[enrollment_id][:changes] = enrollment.changes[:present]
        end
        enrollment.save
        # mise à jour du paiement
        student = enrollment.student
        camp_enrollment = student.camp_enrollments.find_by(camp: camp) if camp
        if school_period && school_period.paid == true && camp_enrollment
          camp_enrollment.update(has_paid: enrollment_params[:has_paid])
        end
      end
      course.update(status: true)

      UpdateEnrollmentsJob.perform_later(course.id, enrollments_params)

      redirection(course, params, "Appel validé", "notice")
    else
      course.update(status: true)
      redirection(course, params, "Aucun élève dans ce cours", "alert")
    end
  end

  def unban_student
    course = Course.find(params[:id])
    camp = Camp.find(params[:camp_id])
    student = Student.find(params[:student_id])
    activities = student.activities.where(camp: camp)
    authorize([:managers, course], policy_class: Managers::CoursePolicy)
    camp_enrollment = student.camp_enrollments.find_by(camp: camp)

    camp_enrollment.update(banished: false, banishment_day: nil, number_of_absences: 0)

    future_courses = camp.courses.joins(activity: :students).where("ends_at > ? AND students.id = ?", Time.current, student.id)

    future_courses.each do |course|
      student.courses << course unless student.courses.include?(course)
    end
    redirect_to managers_academy_path(camp.academy)
    flash[:notice] = "#{student.full_name} a été réintégré(e)"
  end

  private

  def course
    @course ||= Course.find(params[:id])
  end

  def course_params
    params.require(:course).permit(:starts_at, :ends_at)
  end

  def permitted_enrollments_params
    params.require(:enrollments).permit!
  end

  def redirection(course, params, message, style)
    if params[:redirect_to] == 'manager'
      flash[:notice] = message if style == "notice"
      flash[:alert] = message if style == "alert"
      redirect_to managers_course_path(course)
    else
      flash[:notice] = message if style == "notice"
      flash[:alert] = message if style == "alert"
      redirect_to coaches_course_path(course)
    end
  end
end
