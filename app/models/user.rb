class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  attr_accessor :academy_1_id, :academy_2_id, :category_1_id, :category_2_id

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :academies_as_manager, class_name: 'Academy', foreign_key: :manager_id

  has_many :coach_academies, foreign_key: :coach_id, dependent: :destroy
  has_many :academies_as_coach, through: :coach_academies, source: :academy
  has_many :school_periods, through: :academies_as_coach
  has_many :camps, through: :school_periods

  has_many :coach_categories, foreign_key: :coach_id, dependent: :destroy
  has_many :categories, through: :coach_categories

  has_many :coach_camps, foreign_key: :coach_id, dependent: :destroy
  has_many :camps, through: :coach_camps

  has_many :activities, foreign_key: :coach_id, dependent: :destroy
  has_many :courses, through: :activities

  has_many :feedbacks, foreign_key: :coach_id

  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles

  has_many :courses_as_manager, class_name: 'Course', foreign_key: :manager_id
  has_many :courses_as_coach, class_name: 'Course', foreign_key: :coach_id

  def manager?
    roles.any? { |role| role.name == 'manager' }
  end

  def coach?
    roles.any? { |role| role.name == 'coach' }
  end

  def full_name
    if first_name && last_name
      "#{first_name} #{last_name}"
    elsif first_name && !last_name
      first_name
    elsif !first_name && last_name
      last_name
    else
      "No name"
    end
  end

  def next_activities
    activities.joins(:camp).where('camps.ends_at > ?', Time.current).order(:starts_at)
  end

  def next_courses
    courses.where('starts_at > ?', Time.current).order(:starts_at)
  end

  def past_courses
    courses.where('ends_at < ?', Time.current).order(:starts_at)
  end

  def today_courses
    courses.where('DATE(starts_at) = ?', Time.current.to_date).order(:starts_at)
  end

  def missing_attendance
    courses.where('starts_at < ?', Time.current).where('status = ?', false)
  end

  def students
    courses.map(&:students).flatten.uniq
  end

  def academies_ordered
    academies_as_coach.order('coach_academies.created_at')
  end
end
