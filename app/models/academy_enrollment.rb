class AcademyEnrollment < ApplicationRecord
  belongs_to :student
  belongs_to :academy
end
