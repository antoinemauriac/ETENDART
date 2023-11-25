class Category < ApplicationRecord

  validates :super_category, presence: true
  validates :name, presence: true, uniqueness: true

  has_many :activities
  has_many :activity_enrollments, through: :activities
  has_many :courses, through: :activities
  has_many :course_enrollments, through: :courses
  has_many :coach_categories
  has_many :coaches, through: :coach_categories

end
