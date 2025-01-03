class UpdateEnrollmentsJob < ApplicationJob
  queue_as :default

  def perform(course_id, enrollments_params)
    course = Course.find(course_id)
    activity = course.activity
    category = activity.category
    camp = activity.camp if activity.camp
    school_period = camp.school_period if camp
    annual_program = activity.annual_program if activity.annual_program
    academy = activity.academy

    enrollments_params.each do |enrollment_id, student_params|

      enrollment = CourseEnrollment.find(enrollment_id.to_i)
      student = enrollment.student
      activity_enrollment = student.activity_enrollments.find_by(activity: activity)
      camp_enrollment = student.camp_enrollments.find_by(camp: camp) if camp
      school_period_enrollment = student.school_period_enrollments.find_by(school_period: school_period) if school_period
      annual_program_enrollment = student.annual_program_enrollments.find_by(annual_program: annual_program) if annual_program

      update_presence_if_needed(activity_enrollment, enrollment.present)

      if school_period && camp_enrollment
        update_presence_if_needed(camp_enrollment, enrollment.present)
        update_presence_if_needed(school_period_enrollment, enrollment.present)
      end

      if annual_program
        update_presence_if_needed(annual_program_enrollment, enrollment.present)
      end

      ##################################################################
      # CODE DANS LE CAS DES ELEVES EXCLUS ( academy.banished == true )
      ##################################################################

      # if camp_enrollment && category.name != "Accompagnement" && student_params[:changes].present? && academy.banished
      #   # je vérifie si la statut de présence a changé. student_params[:changes] est un array de 2 éléments, le premier est l'ancien statut, le deuxième le nouveau
      #   previous_value = student_params[:changes].first
      #   present = student_params[:present].to_i == 1 ? true : false
      #   if !present && previous_value == true
      #     camp_enrollment.update(number_of_absences: camp_enrollment.number_of_absences + 1)
      #   elsif present && previous_value ==  false
      #     camp_enrollment.update(number_of_absences: camp_enrollment.number_of_absences - 1)
      #   end

      #   if camp_enrollment.number_of_absences >= 2 && camp_enrollment.banished == false
      #     banishment(camp_enrollment, student, course)
      #   elsif camp_enrollment.number_of_absences < 2 && camp_enrollment.banished == true
      #     unban_because_of_late(student, camp_enrollment)
      #   end
      # end
    end


    #########################################################################
    # NB : UN SEUL TSHIRT PEUT ÊTRE DISTRIBUÉ PAR ACADEMY ET PAR STUDENT
    # UNE NOUVELLE OPERATION DE DISTRIBUTION DE TSHIRT EST POSSIBLE
    # DANS CE CAS, ON REMET TOUS LES SCHOOL_PERIOD_ENROLLMENT.TSHIRT_DELIVERED À FALSE
    #########################################################################
    if school_period && school_period.tshirt
      enrollments_params.each do |enrollment_id, student_params|
        student = CourseEnrollment.find(enrollment_id.to_i).student
        school_period_enrollment = student.school_period_enrollments.find_by(school_period: school_period) if school_period
        school_period_enrollments = student.school_period_enrollments
                                           .joins(:school_period)
                                           .where(school_periods: { academy_id: academy.id })
        school_period_enrollments.update_all(tshirt_delivered: school_period_enrollment.tshirt_delivered)
      end
    end
  end


  def update_presence_if_needed(enrollment, course_presence)
    if course_presence && enrollment && !enrollment.present
      enrollment.update(present: true)
    end
  end

  ##################################################################
  # CODE DANS LE CAS DES ELEVES EXCLUS ( academy.banished == true )
  ##################################################################

  # def unban_because_of_late(student, camp_enrollment)
  #   camp = camp_enrollment.camp
  #   camp_enrollment.update(banished: false, banishment_day: nil)
  #   future_courses = camp.courses.joins(activity: :students).where("ends_at > ? AND students.id = ?", Time.current, student.id)
  #   future_courses.each do |course|
  #     student.courses << course unless student.courses.include?(course)
  #   end
  # end

  # def banishment(camp_enrollment, student, course)
  #   camp = course.activity.camp
  #   camp_enrollment.update(banished: true, banishment_day: Time.current)
  #   future_courses = camp.courses.where("starts_at > ?", course.starts_at + 0.5.hour)
  #   student.course_enrollments.where(course: future_courses).destroy_all
  # end
end
