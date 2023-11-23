class AnnualProgramEnrollment < ApplicationRecord
  belongs_to :student
  belongs_to :annual_program

  scope :attended, -> { where(present: true) }
  scope :unattended, -> { where(present: false) }
end
