class Category < ApplicationRecord

  validates :super_category, presence: true
  validates :name, presence: true, uniqueness: true

  has_many :activities
  has_many :activity_enrollments, through: :activities
  has_many :courses, through: :activities
  has_many :course_enrollments, through: :courses
  has_many :coach_categories
  has_many :coaches, through: :coach_categories

  before_validation :normalize_name

  def short_name
    name.length > 9 ? name[0...6] + '...' : name
  end

  private

  def normalize_name
    self.name = name.split.map(&:capitalize).join(' ')
  end
end
