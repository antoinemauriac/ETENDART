class CampEnrollment < ApplicationRecord
  belongs_to :student
  belongs_to :camp
end
