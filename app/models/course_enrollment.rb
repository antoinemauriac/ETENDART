class CourseEnrollment < ApplicationRecord
  belongs_to :student
  belongs_to :course
  has_one :camp, through: :course

  scope :attended, -> { where(present: true) }
  scope :unattended, -> { where(present: false) }

end
