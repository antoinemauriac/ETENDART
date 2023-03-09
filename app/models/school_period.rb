class SchoolPeriod < ApplicationRecord
  belongs_to :academy
  has_many :camps

  has_many :school_period_enrollments, dependent: :destroy
  has_many :students, through: :school_period_enrollments

  def students
    school_period_enrollments.map(&:student)
  end

  def students_count
    students.count
  end
end
