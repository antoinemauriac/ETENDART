class ActivityEnrollment < ApplicationRecord
  # permet d'envoyer un params lors de l'inscription a une activité pour l'envoyer au camp_enrollment
  attr_accessor :payment_method

  belongs_to :student
  belongs_to :activity
  belongs_to :camp_enrollment, optional: true
  has_one :camp, through: :activity

  scope :attended, -> { where(present: true) }
  scope :unattended, -> { where(present: false) }

  scope :confirmed, -> { where(confirmed: true) }
end
