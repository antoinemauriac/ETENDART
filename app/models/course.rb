class Course < ApplicationRecord
  validate :starts_at_before_ends_at

  belongs_to :activity
  has_one :camp, through: :activity
  has_one :school_period, through: :camp
  has_one :academy, through: :school_period

  belongs_to :manager, class_name: 'User'

  has_many :course_enrollments, dependent: :destroy
  has_many :students, through: :course_enrollments


  private

  def starts_at_before_ends_at
    if starts_at.present? && ends_at.present? && starts_at >= ends_at
      errors.add(:starts_at, "must be before end time")
    end
  end
end
