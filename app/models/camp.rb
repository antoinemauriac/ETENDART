class Camp < ApplicationRecord
  belongs_to :school_period
  has_one :academy, through: :school_period
  has_one :academy, through: :school_period
  has_many :coach_academies, through: :academy
  has_many :coaches, through: :coach_academies

  has_many :activities
  has_many :courses, through: :activities

  has_many :camp_enrollments
  has_many :students, through: :camp_enrollments

  has_many :coach_camps
  has_many :coaches, through: :coach_camps

  validates :name, presence: true
  validate :starts_at_must_be_before_ends_at

  def students_count
    students.count
  end

  private

  def starts_at_must_be_before_ends_at
    errors.add(:starts_at, "must be before ends_at") if starts_at >= ends_at
  end
end
