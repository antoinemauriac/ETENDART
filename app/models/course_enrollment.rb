class CourseEnrollment < ApplicationRecord
  belongs_to :student
  belongs_to :course

  scope :attended, -> { where(present: true) }
  scope :unattended, -> { where(present: false) }

end
