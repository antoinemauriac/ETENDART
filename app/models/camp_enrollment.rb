class CampEnrollment < ApplicationRecord
  belongs_to :student
  belongs_to :camp

  scope :attended, -> { where(present: true) }
  scope :unattended, -> { where(present: false) }

  scope :banished, -> { where(banished: true) }

  scope :paid, -> { where(has_paid: true) }
  scope :unpaid, -> { where(has_paid: false) }

end
