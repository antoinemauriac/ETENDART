class CampEnrollment < ApplicationRecord
  belongs_to :student
  belongs_to :camp

  scope :attended, -> { where(present: true) }
  scope :unattended, -> { where(present: false) }
end
