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
  accepts_nested_attributes_for :courses

  belongs_to :location

  validates :name, presence: true
  validates :category_id, presence: true
  validates :coach_id, presence: true

  has_many :activity_enrollments, dependent: :destroy
  has_many :students, through: :activity_enrollments
  # has_many :days
  # accepts_nested_attributes_for :days

  def students_count
    students.count
  end

  def students
    activity_enrollments.map(&:student)
  end

  def can_delete?
    if camp.starts_at
      camp.starts_at > Date.today
    else
      true
    end
  end

end
