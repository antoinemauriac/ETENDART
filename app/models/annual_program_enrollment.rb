class AnnualProgramEnrollment < ApplicationRecord
  belongs_to :student
  belongs_to :annual_program
end
