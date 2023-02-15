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
  has_many :courses
  accepts_nested_attributes_for :courses

  # has_many :days
  # accepts_nested_attributes_for :days

  has_many :activity_enrollments
  has_many :students, through: :activity_enrollments

end
