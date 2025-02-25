class SchoolPeriodEnrollment < ApplicationRecord
  belongs_to :student
  belongs_to :school_period

  scope :attended, -> { where(present: true) }
  scope :unattended, -> { where(present: false) }

  # a l'aide d'un unique form, inscrire son enfant à une school_period + aux camps associés + activités associées
  has_many :camp_enrollments, dependent: :destroy
  has_many :camps, through: :camp_enrollments
  accepts_nested_attributes_for :camp_enrollments, allow_destroy: true
end
