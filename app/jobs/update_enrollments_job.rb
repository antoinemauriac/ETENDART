class UpdateEnrollmentsJob < ApplicationJob
  queue_as :default

  def perform(course_id, enrollments_params)
    course = Course.find(course_id)
    activity = course.activity
    camp = activity.camp if activity.camp
    school_period = camp.school_period if camp
    annual_program = activity.annual_program if activity.annual_program
    academy = activity.academy

    enrollments_params.each do |enrollment_id, student_params|
      
      enrollment = CourseEnrollment.find(enrollment_id.to_i)
      student = enrollment.student

      activity_enrollment = student.activity_enrollments.find_by(activity: activity)
      present_during_activity = student.present_during_activity?(activity, course)

      camp_enrollment = student.camp_enrollments.find_by(camp: camp) if camp
      present_during_camp = student.present_during_camp?(camp, course) if camp

      school_period_enrollment = student.school_period_enrollments.find_by(school_period: school_period) if school_period
      present_during_school_period = student.present_during_school_period?(school_period, course) if school_period

      annual_program_enrollment = student.annual_program_enrollments.find_by(annual_program: annual_program) if annual_program
      present_during_annual_program = student.present_during_annual_program?(annual_program, course) if annual_program

      if activity_enrollment
        if !activity_enrollment.present && enrollment.present
          activity_enrollment.update(present: true)
        elsif activity_enrollment.present && !enrollment.present && !present_during_activity
          activity_enrollment.update(present: false)
        end
      end

      if school_period && school_period_enrollment
        if !school_period_enrollment.present && enrollment.present
          school_period_enrollment.update(present: true)
        elsif school_period_enrollment.present && !enrollment.present && !present_during_school_period
          school_period_enrollment.update(present: false)
        end
      end

      if camp_enrollment && camp_enrollment
        if !camp_enrollment.present && enrollment.present
          camp_enrollment.update(present: true)
        elsif camp_enrollment.present && !enrollment.present && !present_during_camp
          camp_enrollment.update(present: false)
        end
      end

      if annual_program_enrollment && annual_program_enrollment
        if !annual_program_enrollment.present && enrollment.present
          annual_program_enrollment.update(present: true)
        elsif annual_program_enrollment.present && !enrollment.present && !present_during_annual_program
          annual_program_enrollment.update(present: false)
        end
      end
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
end
