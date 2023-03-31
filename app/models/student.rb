class Student < ApplicationRecord

  DEFAULT_AVATAR = "xkhgd88iqzlk5ctay2hu.png"

  scope :today_birthday, -> { where('EXTRACT(month FROM date_of_birth) = ? AND EXTRACT(day FROM date_of_birth) = ?', Date.today.month, Date.today.day).order("created_at DESC") }

  attr_accessor :academy1_id, :academy2_id

  has_one_attached :photo

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

  has_many :feedbacks, dependent: :destroy

  def full_name
    "#{first_name} #{last_name}"
  end

  def courses_sorted
    courses.order(starts_at: :asc)
  end

  def past_courses
    courses.where('starts_at < ?', Time.current)
           .order(starts_at: :desc)
  end

  def unattended_courses
    course_enrollments.unattended
                      .joins(:course)
                      .where('courses.starts_at < ?', Time.current)
  end

  def unattended_today_courses
    course_enrollments.unattended
                      .joins(:course)
                      .where(courses: { ends_at: Date.current.all_day })
  end

  def next_courses
    courses.where('starts_at > ?', Time.current)
           .order(starts_at: :asc)
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

  def self.absent_students(current_user)
    joins(:course_enrollments, courses: :academy)
      .where(course_enrollments: { present: false })
      .where(academies: { id: current_user.academies_as_manager.pluck(:id) })
      .distinct
  end

  def first_academy
    academies.first
  end

  def photo_or_default
    if photo.attached?
      photo.key
    else
      DEFAULT_AVATAR
    end
  end

  def phone_modified
    if phone_number.length == 9
      "0#{phone_number}"
    else
      phone_number
    end
  end
end
