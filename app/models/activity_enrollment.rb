class ActivityEnrollment < ApplicationRecord
  belongs_to :student
  belongs_to :activity
end
