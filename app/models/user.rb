class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  attr_accessor :academy_1_id, :academy_2_id, :academy_3_id, :category_1_id, :category_2_id, :category_3_id

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :first_name, :last_name, :email, presence: true
  validates :email, uniqueness: true

  has_many :academies_as_manager, class_name: 'Academy', foreign_key: :manager_id

  has_many :coach_academies, foreign_key: :coach_id, dependent: :destroy
  has_many :academies_as_coach, through: :coach_academies, source: :academy
  has_many :school_periods, through: :academies_as_coach
  has_many :camps, through: :school_periods

  has_many :coach_categories, foreign_key: :coach_id, dependent: :destroy
  has_many :categories, through: :coach_categories

  has_many :coach_camps, foreign_key: :coach_id, dependent: :destroy
  has_many :camps, through: :coach_camps

  has_many :feedbacks, foreign_key: :coach_id

  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles

  has_many :courses_as_manager, class_name: 'Course', foreign_key: :manager_id
  # has_many :courses, foreign_key: :coach_id

  has_many :activities_as_lead, class_name: 'Activity', foreign_key: :coach_id, dependent: :destroy
  has_many :courses_as_lead, through: :activities_as_lead, source: :courses

  has_many :activity_coaches, foreign_key: :coach_id, dependent: :destroy
  has_many :activities_as_coach, through: :activity_coaches, source: :activity
  has_many :courses_as_coach, through: :activities_as_coach, source: :courses

  has_many :coach_feedbacks, foreign_key: :coach_id, dependent: :destroy

  before_validation :normalize_fields
  before_validation :normalize_phone_number

  def all_activities
    Activity.where(id: activities_as_lead.select(:id)).or(Activity.where(id: activities_as_coach.select(:id))).distinct
  end

  # def all_courses
  #   (courses_as_lead + courses_as_coach ).uniq.sort_by(&:id).map(&:id)
  # end

  def all_courses
    Course.where(id: courses_as_lead.select(:id)).or(Course.where(id: courses_as_coach.select(:id))).distinct
  end

  def manager?
    roles.any? { |role| role.name == 'manager' }
  end

  def coach?
    roles.any? { |role| role.name == 'coach' }
  end

  def full_name
    "#{first_name.capitalize} #{last_name.capitalize}"
  end

  # def next_activities
  #   all_activities.select { |activity| activity.camp.ends_at > Time.current }.sort_by { |activity| activity.camp.starts_at}
  # end

  def next_activities
    activity_ids = Activity.where(id: activities_as_lead.select(:id)).or(Activity.where(id: activities_as_coach.select(:id))).select(:id)
    Activity.joins(:camp).where(id: activity_ids).where('camps.ends_at > ?', Time.current).order(:starts_at)
  end

  # def next_annual_activities
  #   activity_ids = Activity.where(id: activities_as_lead.select(:id)).or(Activity.where(id: activities_as_coach.select(:id))).select(:id)
  #   Activity.joins(:annual_program).where(id: activity_ids).where('annual_programs.ends_at > ?', Time.current).order(:starts_at)
  # end

  def next_annual_activities
    activity_ids = Activity.where(id: activities_as_lead.select(:id))
                        .or(Activity.where(id: activities_as_coach.select(:id)))
                        .select(:id)

    activities = Activity.joins(:annual_program)
                         .where(id: activity_ids)

    activities.select { |activity| activity.annual_program.ends_at > Time.current }
  end

  def next_courses
    all_courses.where('starts_at > ?', Time.current).order(:starts_at)
  end

  def past_courses
    all_courses.where('ends_at < ?', Time.current).order(starts_at: :desc)
  end

  def today_courses
    all_courses.where('DATE(starts_at) = ?', Time.current.to_date).order(:starts_at)
  end

  def missing_attendance
    all_courses.where('starts_at < ?', Time.current).where('status = ?', false)
  end

  def students
    all_courses.map(&:students).flatten.uniq
  end

  def academies_ordered
    academies_as_coach.order('coach_academies.created_at')
  end

  private

  def normalize_fields
    self.first_name = first_name.strip.split.map(&:capitalize).join(' ') if first_name.present?
    self.last_name = last_name.strip.split.map(&:capitalize).join(' ') if last_name.present?
  end

  def normalize_phone_number
    return unless phone_number
    new_phone = phone_number.gsub(/[^0-9]/, '')
    if new_phone.length == 9
      self.phone_number = "0#{new_phone}"
    elsif new_phone.length == 10
      self.phone_number = new_phone
    elsif new_phone.length == 11 && new_phone.start_with?('33')
      self.phone_number = "0#{new_phone[2..-1]}"
    end
  end
end
