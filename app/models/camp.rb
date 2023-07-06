class Camp < ApplicationRecord
  belongs_to :school_period
  has_one :academy, through: :school_period
  has_one :academy, through: :school_period
  has_many :coach_academies, through: :academy
  has_many :coaches, through: :coach_academies

  has_many :activities, dependent: :destroy
  has_many :courses, through: :activities
  has_many :course_enrollments, through: :courses

  has_many :activity_enrollments, through: :activities

  has_many :camp_enrollments, dependent: :destroy
  has_many :students, through: :camp_enrollments

  has_many :coach_camps, dependent: :destroy
  has_many :coaches, through: :coach_camps

  validates :name, presence: true
  validate :starts_at_must_be_before_ends_at

  def banished_students
    students.joins(:camp_enrollments).where(camp_enrollments: { banished: true }).uniq
  end

  def students_count
    students.count
  end

  def number_of_students(genre)
    camp_enrollments.joins(:student).where(students: { gender: genre }).count
  end

  def percentage_of_students(genre)
    if students_count.positive?
      ((number_of_students(genre).to_f / students_count) * 100).round(0)
    else
      0
    end
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

  def can_import?
    if starts_at
      starts_at > Date.today
    else
      true
    end
  end

  def has_begun?
    starts_at <= Date.today
  end

  # def absenteeism_rate
  #   total_enrollments = course_enrollments.count
  #   absent_enrollments = course_enrollments.where(present: false).count
  #   if total_enrollments.positive?
  #     absenteeism_rate = ((absent_enrollments.to_f / total_enrollments) * 100).round(0)
  #   else
  #     absenteeism_rate = 0
  #   end
  # end

  # def absenteeism_rate
  #   enrollments = course_enrollments.joins(:course).where("courses.ends_at < ?", Time.current)
  #   total_enrollments = enrollments.count
  #   absent_enrollments = enrollments.unattended.count

  #   if total_enrollments.positive?
  #     ((absent_enrollments.to_f / total_enrollments) * 100)
  #   else
  #     0
  #   end
  # end

  def absenteeism_rate
    enrollments = course_enrollments.joins(course: { activity: :category })
                                   .where("courses.ends_at < ? AND categories.name != ?", Time.current, "Accompagnement")
    total_enrollments = enrollments.count
    absent_enrollments = enrollments.unattended.count

    if total_enrollments.positive?
      ((absent_enrollments.to_f / total_enrollments) * 100).round(0)
    else
      0
    end
  end

  def no_show_count
    students_count = course_enrollments.joins(:student)
                                      .group(:student_id)
                                      .having("COUNT(*) = SUM(CASE WHEN present = false THEN 1 ELSE 0 END)")
                                      .count.keys.count

    students_count
  end

  def no_show_rate
    if students_count.positive?
      ((no_show_count.to_f / students_count) * 100).round(0)
    else
      0
    end
  end


  private

  def starts_at_must_be_before_ends_at
    errors.add(:starts_at, :after) if starts_at >= ends_at
  end

end
