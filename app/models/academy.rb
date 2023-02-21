class Academy < ApplicationRecord
  has_many :locations
  has_many :school_periods
  has_many :camps, through: :school_periods
  has_many :activities, through: :camps

  belongs_to :manager, class_name: 'User'
  has_many :coach_academies
  has_many :coaches, through: :coach_academies

  has_many :academy_enrollments
  has_many :students, through: :academy_enrollments
end
