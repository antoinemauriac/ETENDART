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
    @school_period = course.school_period
    @category = course.category
    @activity = course.activity
    @banished_students = @activity.banished_students.where.not(id: @enrollments.pluck(:student_id))
    authorize([:managers, @course], policy_class: Managers::CoursePolicy)
  end

  def edit
    authorize([:managers, @course], policy_class: Managers::CoursePolicy)
  end

  def update
    authorize([:managers, @course], policy_class: Managers::CoursePolicy)
    if course.update(course_params)
      redirect_to managers_activity_path(course.activity)
      flash[:notice] = "Cours mis à jour"
    else
      flash[:alert] = "L'heure de début doit être avant l'heure de fin"
      redirect_to managers_activity_path(course.activity)
    end
  end

  def destroy
    authorize([:managers, @course], policy_class: Managers::CoursePolicy)
    course.destroy
    redirect_to managers_activity_path(course.activity)
    flash[:notice] = "Cours supprimé"
  end

  def update_enrollments
    course = Course.find(params[:id])
    school_period = course.school_period
    academy = course.activity.academy
    enrollments_params = params[:enrollments]
    authorize([:managers, @enrollments], policy_class: Managers::CoursePolicy)

    if enrollments_params.present?
      enrollments_params.each do |enrollment_params|

        enrollment = CourseEnrollment.find(enrollment_params[0].to_i)
        student = enrollment.student

        if school_period.paid == true
          camp_enrollment = student.camp_enrollments.find_by(camp: course.activity.camp)
          camp_enrollment&.update(has_paid: enrollment_params[1][:has_paid])
        end


        if academy.name == "Rudy Gobert"
          if enrollment_params[1][:present].to_i == 0 && enrollment.present == true
            camp_enrollment.update(number_of_absences: camp_enrollment.number_of_absences + 1)
          elsif enrollment_params[1][:present].to_i == 1 && enrollment.present == false
            camp_enrollment.update(number_of_absences: camp_enrollment.number_of_absences - 1)
          end

          if camp_enrollment.number_of_absences >= 2
            banishment(camp_enrollment, student, course)
          elsif camp_enrollment.number_of_absences < 2 && camp_enrollment.banished == true
            unban_because_of_late(student, camp_enrollment)
          end
        end

        enrollment.update(present: enrollment_params[1][:present].to_i)
      end
      course.update(status: true)

      redirection(course, params, "Appel validé", "notice")
    else
      redirection(course, params, "Aucun élève dans ce cours", "alert")
    end
  end

  def unban_because_of_late(student, camp_enrollment)
    camp = camp_enrollment.camp
    camp_enrollment.update(banished: false)
    future_courses = camp.courses.joins(activity: :students).where("starts_at > ? AND students.id = ?", Time.current, student.id)
    # ré-inscrire le student aux cours futurs
    future_courses.each do |course|
      course.course_enrollments.create(student: student) unless course.course_enrollments.find_by(student: student)
    end
  end

  def unban_student
    course = Course.find(params[:id])
    camp = Camp.find(params[:camp_id])
    student = Student.find(params[:student_id])
    authorize([:managers, course], policy_class: Managers::CoursePolicy)
    camp_enrollment = student.camp_enrollments.find_by(camp: camp)
    # débannir le student du camp
    camp_enrollment.update(banished: false)
    camp_enrollment.update(number_of_absences: 0)
    # future_courses = camp.courses.where("starts_at > ?", Time.current)
    future_courses = camp.courses.joins(activity: :students).where("starts_at > ? AND students.id = ?", Time.current, student.id)

    # ré-inscrire le student aux cours futurs
    future_courses.each do |course|
      course.course_enrollments.create(student: student) unless course.course_enrollments.find_by(student: student)
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

  def banishment(camp_enrollment, student, course)
    camp = course.activity.camp
    camp_enrollment.update(banished: true)
    future_courses = camp.courses.where("starts_at > ?", course.starts_at + 1.hour)
    student.course_enrollments.where(course: future_courses).destroy_all
  end

  def redirection(course, params, message, style)
    respond_to do |format|
      format.html do
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
      format.json { head :no_content }
    end
  end
end
