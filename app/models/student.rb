class Student < ApplicationRecord

  attr_accessor :academy1_id, :academy2_id

  has_many :academy_enrollments, dependent: :destroy
  has_many :academies, through: :academy_enrollments

  has_many :school_period_enrollments, dependent: :destroy
  has_many :school_periods, through: :school_period_enrollments

  has_many :camp_enrollments, dependent: :destroy
  has_many :camps, through: :camp_enrollments

  has_many :activity_enrollments, dependent: :destroy
  has_many :activities, through: :activity_enrollments

  has_many :course_enrollments, dependent: :destroy
  has_many :courses, through: :course_enrollments

  has_many :feedbacks


  def courses_sorted
    courses.order(starts_at: :asc)
  end

  def past_courses
    courses.where('ends_at < ?', Time.current).order(starts_at: :asc)
  end

  def unattended_courses
    course_enrollments.unattended.joins(:course).where('courses.ends_at < ?', Time.current)
  end

  def next_courses
    courses.where('starts_at > ?', Time.current).order(starts_at: :asc)
  end

  def courses_count
    courses.count
  end

  def past_courses_count
    courses.where('ends_at < ?', Time.current).count
  end

  def unattended_courses_count
    course_enrollments.unattended.joins(:course).where('courses.ends_at < ?', Time.current).count
  end

  def unattended_rate
    if past_courses_count.positive?
      (unattended_courses_count.to_f / past_courses_count * 100).round
    else
      0
    end
  end

  def activities_count
    activities.count
  end

  def camps_count
    camps.count
  end

  def student_activities(camp)
    activities.where(camp: camp)
  end

  def age
    if date_of_birth
      now = Time.current
      birthdate = date_of_birth.to_date
      age = now.year - birthdate.year
      age -= 1 if birthdate.strftime("%m%d").to_i > now.strftime("%m%d").to_i
      age
    end
  end

  def next_activities
    activities.joins(:camp).where('camps.ends_at > ?', Time.current).order('camps.starts_at ASC')
  end
end
