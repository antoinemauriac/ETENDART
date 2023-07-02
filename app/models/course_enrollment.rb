class CourseEnrollment < ApplicationRecord
  belongs_to :student
  belongs_to :course
  has_one :activity, through: :course
  has_one :camp, through: :course
  has_one :school_period, through: :camp

  scope :attended, -> { where(present: true) }
  scope :unattended, -> { where(present: false) }

end
