class SchoolPeriod < ApplicationRecord

  MESSAGE = "Avant de valider, avez vous-vérifier que les dates des camps sont correctes ?"

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
    camps.minimum(:starts_at) if camps.any?
  end

  def can_import?
    if starts_at
      starts_at > Date.today
    else
      true
    end
  end
end
