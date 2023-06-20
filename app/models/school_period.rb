class SchoolPeriod < ApplicationRecord

  MESSAGE = "Avant de valider, avez vous-vérifier que les dates des camps sont correctes ?"

  belongs_to :academy
  has_many :camps, dependent: :destroy
  has_many :camp_enrollments, through: :camps
  has_many :students, through: :camp_enrollments

  has_many :activities, through: :camps
  has_many :courses, through: :activities
  has_many :course_enrollments, through: :courses

  has_many :school_period_enrollments, dependent: :destroy
  # has_many :students, through: :school_period_enrollments

  # def students
  #   school_period_enrollments.map(&:student)
  # end

  def full_name
    "#{name} - #{year}"
  end

  def students_count
    students.count
  end

  def total_number_of_students(genre)
    camp_enrollments.joins(:student).where(students: { gender: genre }).count
  end

  def percentage_of_students(genre)
    if students_count.positive?
      ((total_number_of_students(genre).to_f / students_count) * 100).round(0)
    else
      0
    end
  end

  def age_of_students
    (students.map(&:age).sum.to_f / students.count).round(1)
  end

  def participant_ages
    students.map(&:age).uniq.sort
  end

  def number_of_students_by_age(age)
    students.map(&:age).count(age)
  end

  def participant_departments
    students.map(&:department).uniq.sort
  end

  def number_of_students_by_department(department)
    students.map(&:department).count(department)
  end

  def starts_at
    camps.minimum(:starts_at) if camps.any?
  end

  def absenteeism_rate
    total_enrollments = course_enrollments.count
    absent_enrollments = course_enrollments.where(present: false).count
    if total_enrollments.positive?
      ((absent_enrollments.to_f / total_enrollments) * 100).round(0)
    else
      0
    end
  end

  def can_import?
    if starts_at
      starts_at > Date.today
    else
      true
    end
  end
end
