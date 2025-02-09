class Course < ApplicationRecord

  belongs_to :activity
  has_one :category, through: :activity
  has_one :camp, through: :activity
  has_one :school_period, through: :camp

  has_one :annual_program, through: :activity

  belongs_to :manager, class_name: 'User', foreign_key: :manager_id
  belongs_to :coach, class_name: 'User', optional: true

  has_many :course_enrollments, dependent: :destroy
  has_many :students, through: :course_enrollments

  # after_update_commit -> { broadcast_replace_to "today_courses", partial: "managers/academies/today_course", locals: { course: self, academy: academy }, target: self }
  # after_update_commit -> { broadcast_remove_to "today_courses", target: "old_course_#{id}" }

  validates :starts_at, presence: true
  validates :ends_at, presence: true
  validate :starts_at_before_ends_at
  
  def academy
    return camp.academy if camp
    return annual_program.academy if annual_program

    nil
  end

  def coaches
    activity.coaches
  end

  def banished_students
    students.joins(camp_enrollments: { camp: { activities: :courses } })
            .where(camp_enrollments: { banished: true }, courses: { id: id })
            .distinct
  end

  def banished_students_count
    banished_students.count
  end

  def student_presence(student)
    course_enrollments.find_by(student: student).present
  end

  def missing_students
    students.where(id: course_enrollments.where(present: false).pluck(:student_id))
  end

  def students_count
    students.count
  end

  def missing_students_count
    missing_students.count
  end

  def present_students_count
    students_count - missing_students_count
  end

  private

  def starts_at_before_ends_at
    if starts_at.present? && ends_at.present? && starts_at >= ends_at
      errors.add(:starts_at, "L'heure de début doit être avant l'heure de fin")
    end
  end
end
