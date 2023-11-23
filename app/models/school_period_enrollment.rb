class SchoolPeriodEnrollment < ApplicationRecord
  belongs_to :student
  belongs_to :school_period

  scope :attended, -> { where(present: true) }
  scope :unattended, -> { where(present: false) }
end
