class SchoolPeriod < ApplicationRecord

  MESSAGE = "Avant de valider, avez vous-vérifier que les dates des camps sont correctes ?"

  belongs_to :academy
  has_many :camps, dependent: :destroy
  has_many :coaches, through: :camps
  has_many :camp_enrollments, through: :camps
  has_many :students, through: :camp_enrollments

  has_many :students, through: :camp_enrollments

  has_many :activities, through: :camps
  has_many :activity_enrollments, through: :activities
  has_many :categories, -> { distinct }, through: :activities
  has_many :courses, through: :activities
  has_many :course_enrollments, through: :courses

  has_many :school_period_enrollments, dependent: :destroy

  has_one :school_period_stat, dependent: :destroy

  validates :name, uniqueness: { scope: [:year, :academy_id], message: "Un stage avec le même nom et la même année existe déjà pour cette académie." }

  before_validation :normalize_name

  def full_name
    "#{name} - #{year}"
  end

  def students_count
    students.count
  end

  def show_students_ids
    camps.map(&:show_students).flatten.pluck(:id)
  end

  def show_students
    show_students_ids.map { |student_id| Student.find(student_id) }
  end

  def show_count
    camps.sum(&:show_count)
  end

  def show_rate
    if students_count.positive?
      ((show_count.to_f / students_count) * 100).round(0)
    else
      0
    end
  end

  def no_show_count
    camps.sum(&:no_show_count)
  end

  def no_show_rate
    if students_count.positive?
      ((no_show_count.to_f / students_count) * 100).round(0)
    else
      0
    end
  end

  def total_number_of_students(genre)
    show_students.count { |student| student.gender == genre }
  end

  def percentage_of_students(genre)
    if show_count.positive?
      ((total_number_of_students(genre).to_f / show_count) * 100).round(0)
    else
      0
    end
  end

  def age_of_students
    (show_students.map(&:age).sum.to_f / show_count).round(1)
  end

  def participant_ages
    show_students.map(&:age).uniq.sort
  end

  def number_of_students_by_age(age)
    show_students.map(&:age).count(age)
  end

  def participant_departments
    students.map(&:department).uniq.sort
  end

  def number_of_students_by_department(department)
    show_students.map(&:department).count(department.to_s)
  end

  def starts_at
    camps.any? ? camps.minimum(:starts_at) : Date.current + 1.day
  end

  def ends_at
    camps.any? ? camps.maximum(:ends_at) : Date.current + 10.days
  end

  def ended?
    ends_at <= Date.current if ends_at
  end

  def current?
    ends_at >= Date.current - 7.days if ends_at
  end

  def absenteeism_rate
    total_enrollments = camps.sum(&:total_enrollments_count)
    absent_enrollments = camps.sum(&:absent_enrollments_count)

    if total_enrollments.positive?
      ((absent_enrollments.to_f / total_enrollments) * 100).round(0)
    else
      0
    end
  end

  def absenteeism_rate_by_category(category)
    activities = Activity.where(camp: camps, category: category)
    total_enrollments_count = activities.sum { |activity| activity.enrollments_without_no_show.count }
    absent_enrollments_count = activities.sum { |activity| activity.absent_enrollments_count }
    if total_enrollments_count.positive?
      ((absent_enrollments_count.to_f / total_enrollments_count) * 100).round(0)
    else
      0
    end
  end

  def number_of_students_by_category(category)
    activity_enrollments.joins(:activity)
                        .where(activities: { category: category })
                        .count
  end

  def number_of_present_students_by_category(category)
    activity_enrollments.joins(:activity)
                        .where(present: true)
                        .where(activities: { category: category })
                        .count
  end

  def number_of_students_by_category_and_gender(category, gender)
    activity_enrollments.joins(:student, activity: :category)
                        .where(present: true)
                        .where(activities: { category: category }, students: { gender: gender })
                        .count
  end

  def percentage_of_students_by_category_and_gender(category, gender)
    if number_of_present_students_by_category(category).positive?
      ((number_of_students_by_category_and_gender(category, gender).to_f / number_of_present_students_by_category(category)) * 100).round(0)
    else
      0
    end
  end

  def number_of_coaches_by_category(category)
    coaches.joins(activities: :camp)
           .where('activities.category_id = ? AND activities.camp_id IN (?)', category.id, camps.pluck(:id))
           .distinct
           .count
  end

  def can_import?
    if starts_at
      starts_at > Date.current
    else
      true
    end
  end

  def coaches_by_genre(genre)
    coaches.select { |coach| coach.gender == genre }
  end

  def new_students_count
    camps.sum(&:new_students_count)
  end

  private

  def normalize_name
    self.name = name.split.map(&:capitalize).join(' ')
  end
end
