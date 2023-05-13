class Activity < ApplicationRecord

  DAYS = {
    Monday: { start_time: nil, end_time: nil },
    Tuesday: { start_time: nil, end_time: nil },
    Wednesday: { start_time: nil, end_time: nil },
    Thursday: { start_time: nil, end_time: nil },
    Friday: { start_time: nil, end_time: nil }
  }

  belongs_to :camp
  has_one :school_period, through: :camp
  has_one :academy, through: :school_period
  belongs_to :category
  belongs_to :coach, class_name: 'User'
  has_many :courses, dependent: :destroy
  has_many :course_enrollments, through: :courses
  accepts_nested_attributes_for :courses

  belongs_to :location

  validates :name, presence: true
  validates :category_id, presence: true
  validates :coach_id, presence: true

  has_many :activity_enrollments, dependent: :destroy
  has_many :students, through: :activity_enrollments
  # has_many :days
  # accepts_nested_attributes_for :days

  def absenteeism_rate
    total_enrollments = course_enrollments.count
    absent_enrollments = course_enrollments.where(present: false).count

    absenteeism_rate = (absent_enrollments.to_f / total_enrollments) * 100
    return absenteeism_rate.round(0)
  end

  def number_of_students(genre)
    activity_enrollments.joins(:student).where(students: { gender: genre }).count
  end

  def students_count
    students.count
  end

  def students
    activity_enrollments.map(&:student)
  end

  def age_of_students
    (students.map(&:age).sum.to_f / students.count).round(1)
  end

  def can_delete?
    if camp.starts_at
      camp.starts_at > Date.today
    else
      true
    end
  end

end
