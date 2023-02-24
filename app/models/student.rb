class Student < ApplicationRecord
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


  def courses_count
    courses.count
  end

  def past_courses_count
    courses.where('ends_at < ?', Time.now).count
  end

  def unattended_courses_count
    courses.where('ends_at < ? AND present = ?', Time.now, false).count
  end

  def unattended_rate
    if past_courses_count > 0
      ((unattended_courses_count.to_f / past_courses_count.to_f * 100).round).to_i
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
end
