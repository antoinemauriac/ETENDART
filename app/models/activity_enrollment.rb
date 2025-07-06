class ActivityEnrollment < ApplicationRecord
  # permet d'envoyer un params lors de l'inscription a une activité pour l'envoyer au camp_enrollment
  attr_accessor :payment_method

  belongs_to :student
  belongs_to :activity
  belongs_to :camp_enrollment, optional: true
  has_one :camp, through: :activity

  scope :attended, -> { where(present: true) }
  scope :unattended, -> { where(present: false) }

  scope :confirmed, -> { where(confirmed: true) }

  after_destroy :destroy_course_enrollments

  def destroy_course_enrollments
    next_course_enrollments = student.course_enrollments.where(course: activity.next_courses)
    next_course_enrollments&.destroy_all

    past_course_enrollments = student.course_enrollments.where(course: activity.past_courses)
    if past_course_enrollments.attended.count.zero?
      past_course_enrollments&.destroy_all
    end

    if activity.camp
      camp = activity.camp
      camp_enrollment = student.camp_enrollments.find_by(camp:)
      school_period = camp.school_period

      student_camp_courses = student.courses.joins(:activity).where("activities.camp_id = ?", camp.id)
      if student_camp_courses.empty? && camp_enrollment&.paid == false
        camp_enrollment&.destroy
      end

      camp_enrollments = student.camp_enrollments.where(camp: school_period.camps)
      if camp_enrollments.empty?
        student.school_period_enrollments.find_by(school_period: school_period)&.destroy
      end
    end

    if activity.annual_program
      annual_program_enrollment = student.annual_program_enrollments.find_by(annual_program: activity.annual_program)
      annual_program = activity.annual_program
      student_annual_courses = student.courses.joins(:activity).where("activities.annual_program_id = ?", annual_program.id)

      if student_annual_courses.empty? && annual_program_enrollment&.paid == false
        student.annual_program_enrollments.find_by(annual_program:)&.destroy
      end
    end
  end
end
