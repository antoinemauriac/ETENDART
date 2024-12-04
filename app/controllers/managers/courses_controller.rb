class Managers::CoursesController < ApplicationController
  before_action :course, only: %i[edit show update destroy unban_student]
  before_action :authorize_course, only: %i[edit show update destroy unban_student]

  def index
    @courses = current_user.courses_as_manager.sort_by(&:starts_at)
    skip_policy_scope
    authorize([:managers, @courses], policy_class: Managers::CoursePolicy)
  end

  def show
    @enrollments = course.course_enrollments
                         .includes(student: [:photo_attachment, :camp_enrollments])
                         .joins(:student)
                         .order('students.last_name ASC')

    @academy = course.academy
    @activity = course.activity
    @school_period = course.school_period if course.school_period
    @camp = course.camp if course.camp
    @annual_program = @activity.annual_program if @activity.annual_program
    @category = course.category
    @activity = course.activity
    @banished_students = @activity.banished_students.where.not(id: @enrollments.pluck(:student_id)).order(last_name: :asc)
    @present_students_count = @course.present_students_count
    @missing_students_count = @course.missing_students_count
  end

  def edit
  end

  def update
    if course.update(course_params)
      redirect_to correct_activity_path(course.activity), notice: "Cours mis à jour"
    else
      flash[:alert] = "L'heure de début doit être avant l'heure de fin"
      redirect_to correct_activity_path(course.activity)
    end
  end

  def destroy
    course.destroy
    redirect_to correct_activity_path(course.activity), notice: "Cours supprimé"
  end

  def update_enrollments
    @course = Course.find(params[:id])
    authorize([:managers, @course], policy_class: Managers::CoursePolicy)
    @activity = course.activity
    @academy = @activity.academy
    @category = @activity.category
    @camp = @activity.camp if @activity.camp
    @school_period = @camp.school_period if @camp

    enrollments_params = permitted_enrollments_params.to_h

    if enrollments_params.present?
      enrollments_params.each do |enrollment_id, student_params|
        enrollment = CourseEnrollment.find(enrollment_id.to_i)
        enrollment.present = student_params[:present].to_i
        if @school_period && @school_period.paid == true
          update_student_tshirt(enrollment, student_params, @school_period)
        end
        enrollment.save
      end
      @course.update(status: true)
      UpdateEnrollmentsJob.perform_later(@course.id, enrollments_params)
      flash.now[:notice] = "Appel validé"
    else
      @course.update(status: true)
      flash.now[:alert] = "Aucun élève dans ce cours"
    end

    @enrollments = @course.course_enrollments
                         .includes(student: [:photo_attachment, :camp_enrollments])
                         .joins(:student)
                         .order('students.last_name ASC')

    @present_students_count = @course.course_enrollments.where(present: true).count
    @missing_students_count = @course.course_enrollments.where(present: false).count

    respond_to do |format|
      format.turbo_stream
      format.html do
        if params[:redirect_to] == 'manager'
          redirect_to managers_course_path(@course)
        else
          redirect_to coaches_course_path(@course)
        end
      end
    end
  end

  def unban_student
    camp = Camp.find(params[:camp_id])
    student = Student.find(params[:student_id])
    activities = student.activities.where(camp: camp)

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

  def authorize_course
    authorize([:managers, @course], policy_class: Managers::CoursePolicy)
  end

  def update_student_tshirt(enrollment, student_params, school_period)
    student = enrollment.student
    school_period_enrollment = student.school_period_enrollments.find_by(school_period: school_period)
    if school_period && school_period.tshirt == true && school_period_enrollment.tshirt_delivered == false && student_params[:tshirt_delivered] == "1"
      school_period_enrollment.update(tshirt_delivered: true)
      student.update(number_of_tshirts: student.number_of_tshirts + 1)
    elsif school_period && school_period.tshirt == true && school_period_enrollment.tshirt_delivered == true && student_params[:tshirt_delivered] == "0"
      school_period_enrollment.update(tshirt_delivered: false)
      student.update(number_of_tshirts: student.number_of_tshirts - 1)
    end
  end

  # def redirection(course, params, message, style)
  #   if params[:redirect_to] == 'manager'
  #     flash[style.to_sym] = message
  #     redirect_to managers_course_path(course)
  #   else
  #     flash[style.to_sym] = message
  #     redirect_to coaches_course_path(course)
  #   end
  # end
  # def redirection(course, params, message, style)
  #   flash[style.to_sym] = message

  #   respond_to do |format|
  #     format.turbo_stream
  #     format.html do
  #       if params[:redirect_to] == 'manager'
  #         redirect_to managers_course_path(course)
  #       else
  #         redirect_to coaches_course_path(course)
  #       end
  #     end
  #   end
  # end

  def correct_activity_path(activity)
    if activity.camp
      managers_activity_path(activity)
    else
      show_for_annual_managers_activity_path(activity)
    end
  end
end
