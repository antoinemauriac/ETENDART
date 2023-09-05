class Academy < ApplicationRecord
  has_one_attached :image

  has_many :locations
  has_many :school_periods
  has_many :camps, through: :school_periods
  has_many :activities, through: :camps
  has_many :courses, through: :activities

  has_many :annual_programs

  belongs_to :manager, class_name: 'User'
  has_many :coach_academies
  has_many :coaches, through: :coach_academies

  has_many :academy_enrollments
  has_many :students, through: :academy_enrollments

  def today_courses
    courses.where(starts_at: Time.current.all_day).order(:starts_at)
  end

  def tomorrow_courses
    courses.where(starts_at: Time.current.tomorrow.all_day).order(:starts_at)
  end

  def today_absent_students
    students.joins(courses: :course_enrollments)
           .where(course_enrollments: { present: false })
           .where(courses: { starts_at: Time.current.all_day })
           .distinct
           .order(:last_name)
  end

end
