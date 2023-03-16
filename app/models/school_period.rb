class SchoolPeriod < ApplicationRecord
  belongs_to :academy
  has_many :camps, dependent: :destroy

  has_many :school_period_enrollments, dependent: :destroy
  has_many :students, through: :school_period_enrollments

  def students
    school_period_enrollments.map(&:student)
  end

  def students_count
    students.count
  end

  def starts_at
    camps.minimum(:starts_at)
  end

  def can_import?
    starts_at > Date.today
  end
end
