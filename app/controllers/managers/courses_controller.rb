class Managers::CoursesController < ApplicationController
  before_action :course, only: %i[edit show update destroy]
  # before_action :set_cache_headers, only: [:show]

  def index
    @courses = current_user.courses_as_manager.sort_by(&:starts_at)
    skip_policy_scope
    authorize([:managers, @courses], policy_class: Managers::CoursePolicy)
  end

  def show
    @start_year = @course.starts_at.month >= 9 ? Date.current.year : Date.current.year - 1
    @enrollments = course.course_enrollments.joins(:student).order(last_name: :asc)
    @academy = course.academy
    @school_periods = @academy.school_periods
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
      redirect_to correct_activity_path(course.activity), notice: "Cours mis à jour"
    else
      flash[:alert] = "L'heure de début doit être avant l'heure de fin"
      redirect_to correct_activity_path(course.activity)
    end
  end

  def destroy
    authorize([:managers, @course], policy_class: Managers::CoursePolicy)
    course.destroy
    redirect_to correct_activity_path(course.activity), notice: "Cours supprimé"
  end

  def update_enrollments
    course = Course.find(params[:id])
    academy = course.academy
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
        # mise à jour du tshirt
        school_period_enrollment = student.school_period_enrollments.find_by(school_period: school_period)
        if school_period && school_period.tshirt == true && school_period_enrollment.tshirt_delivered == false && enrollment_params[:tshirt_delivered] == "1"
          school_period_enrollment.update(tshirt_delivered: true)
          student.update(number_of_tshirts: student.number_of_tshirts + 1)
        elsif school_period && school_period.tshirt == true && school_period_enrollment.tshirt_delivered == true && enrollment_params[:tshirt_delivered] == "0"
          school_period_enrollment.update(tshirt_delivered: false)
          student.update(number_of_tshirts: student.number_of_tshirts - 1)
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

  def correct_activity_path(activity)
    if activity.camp
      managers_activity_path(activity)
    else
      show_for_annual_managers_activity_path(activity)
    end
  end
end
