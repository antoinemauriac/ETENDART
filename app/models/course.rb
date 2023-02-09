class Course < ApplicationRecord
  belongs_to :activity
  has_one :camp, through: :activity
  has_one :school_period, through: :camp
  has_one :academy, through: :school_period

  belongs_to :manager, class_name: 'User'

  has_many :course_enrollments
  has_many :students, through: :course_enrollments
end
