class ActivityEnrollment < ApplicationRecord
  belongs_to :student
  belongs_to :activity
  has_one :camp, through: :activity
end
