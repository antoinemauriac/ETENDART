class Category < ApplicationRecord

  validates :super_category, presence: true
  validates :name, presence: true, uniqueness: true

  has_many :activities
  has_many :courses, through: :activities
  has_many :course_enrollments, through: :courses
  has_many :coach_categories
  has_many :coaches, through: :coach_categories

  # def absenteeism_rate_by_school_period(school_period)
  #   enrollments = course_enrollments.joins(:course).where("courses.ends_at < ?", Time.current).where("courses.school_period_id = ?", school_period.id)
  #   total_enrollments = enrollments.count
  #   absent_enrollments = enrollments.unattended.count

  #   if total_enrollments.positive?
  #     ((absent_enrollments.to_f / total_enrollments) * 100).round(0)
  #   else
  #     0
  #   end
  # end

end
