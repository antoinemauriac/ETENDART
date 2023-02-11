class Activity < ApplicationRecord
  belongs_to :camp
  has_one :school_period, through: :camp
  has_one :academy, through: :school_period
  belongs_to :category
  belongs_to :coach, class_name: 'User'
  has_many :courses

  has_many :activity_enrollments
  has_many :students, through: :activity_enrollments

  serialize :days, Hash
end
