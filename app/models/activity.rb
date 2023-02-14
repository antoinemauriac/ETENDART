class Activity < ApplicationRecord

  DAYS = {
    Lundi: { start_time: Time.parse("10:00"), end_time: Time.parse("12:00") },
    Mardi: { start_time: Time.parse("10:00"), end_time: Time.parse("12:00") },
    Mercredi: { start_time: Time.parse("10:00"), end_time: Time.parse("12:00") },
    Jeudi: { start_time: Time.parse("10:00"), end_time: Time.parse("12:00") },
    Vendredi: { start_time: Time.parse("10:00"), end_time: Time.parse("12:00") }
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
