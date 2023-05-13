class Camp < ApplicationRecord
  belongs_to :school_period
  has_one :academy, through: :school_period
  has_one :academy, through: :school_period
  has_many :coach_academies, through: :academy
  has_many :coaches, through: :coach_academies

  has_many :activities, dependent: :destroy
  has_many :courses, through: :activities

  has_many :camp_enrollments, dependent: :destroy
  has_many :students, through: :camp_enrollments

  has_many :coach_camps, dependent: :destroy
  has_many :coaches, through: :coach_camps

  validates :name, presence: true
  validate :starts_at_must_be_before_ends_at

  def students_count
    students.count
  end

  def number_of_students(genre)
    camp_enrollments.joins(:student).where(students: { gender: genre }).count
  end

  def age_of_students
    (students.map(&:age).sum.to_f / students.count).round(1)
  end

  def students_with_activity_enrollment
    students.joins(:activity_enrollments)
            .where(activity_enrollments: { activity_id: activities })
            .distinct
            .order(:last_name)
  end

  def can_delete?
    if starts_at
      starts_at > Date.today
    else
      true
    end
  end

  def participant_ages
    students.map(&:age).uniq.sort
  end

  def number_of_students_by_age(age)
    students.select { |student| student.age == age }.count
  end

  def number_of_students_by_dpt(department)
    students.select { |student| student.department == department }.count
  end

  private

  def starts_at_must_be_before_ends_at
    errors.add(:starts_at, :after) if starts_at >= ends_at
  end

end
