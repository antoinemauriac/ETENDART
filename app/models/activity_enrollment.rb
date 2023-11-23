class ActivityEnrollment < ApplicationRecord
  belongs_to :student
  belongs_to :activity
  has_one :camp, through: :activity

  scope :attended, -> { where(present: true) }
  scope :unattended, -> { where(present: false) }
end
