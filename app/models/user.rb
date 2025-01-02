class User < ApplicationRecord
  include PgSearch::Model

  pg_search_scope :search_by_query, against: [:first_name, :last_name],
  associated_against: {
    academies_as_coach: [:name],
    categories: [:name]
  },
  using: {
    tsearch: { prefix: true }
  }

  attr_accessor :academy_1_id, :academy_2_id, :academy_3_id, :category_1_id, :category_2_id, :category_3_id, :category_4_id, :category_5_id

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  validates :first_name, presence: { message: 'Le prénom est obligatoire' }
  validates :last_name, presence: { message: 'Le nom est obligatoire' }
  validates :email, presence: { message: 'L\'email est obligatoire' }

  validates :email, uniqueness: true

  has_many :memberships, foreign_key: :receiver_id

  has_many :academies_as_manager, class_name: 'Academy', foreign_key: :manager_id
  has_many :academies_as_coordinator, class_name: 'Academy', foreign_key: :coordinator_id

  has_many :membership_deposits_as_manager, class_name: 'MembershipDeposit', foreign_key: :manager_id
  has_many :membership_deposits_as_depositor, class_name: 'MembershipDeposit', foreign_key: :depositor_id

  has_many :camp_deposits_as_manager, class_name: 'CampDeposit', foreign_key: :manager_id
  has_many :camp_deposits_as_depositor, class_name: 'CampDeposit', foreign_key: :depositor_id

  has_many :old_camp_deposits

  has_many :coach_academies, foreign_key: :coach_id, dependent: :destroy
  has_many :academies_as_coach, through: :coach_academies, source: :academy
  # has_many :school_periods, through: :academies_as_coach
  # has_many :camps, through: :school_periods

  has_many :coach_categories, foreign_key: :coach_id, dependent: :destroy
  has_many :categories, through: :coach_categories

  has_many :coach_camps, foreign_key: :coach_id, dependent: :destroy
  has_many :camps, through: :coach_camps

  has_many :feedbacks, foreign_key: :coach_id

  has_many :user_roles, dependent: :destroy
  has_many :roles, through: :user_roles

  has_many :courses_as_manager, class_name: 'Course', foreign_key: :manager_id

  has_many :activity_coaches, foreign_key: :coach_id, dependent: :destroy
  has_many :activities, through: :activity_coaches
  has_many :courses, through: :activities
  has_many :course_enrollments, through: :courses
  has_many :students, through: :course_enrollments

  has_many :coach_feedbacks, foreign_key: :coach_id, dependent: :destroy

  before_validation :normalize_fields
  before_validation :normalize_phone_number

  def academies
    if admin?
      Academy.all
    elsif manager?
      academies_as_manager
    elsif coordinator?
      academies_as_coordinator
    end
  end

  def admin?
    roles.any? { |role| role.name == 'admin' }
  end

  def coordinator?
    roles.any? { |role| role.name == 'coordinator' }
  end

  def manager?
    roles.any? { |role| role.name == 'manager' }
  end

  def coach?
    roles.any? { |role| role.name == 'coach' }
  end

  def parent?
    roles.any? { |role| role.name == 'parent' }
  end

  def manager_or_coordinator?
    manager? || coordinator?
  end

  def no_role?
    roles.empty?
  end

  def full_name
    "#{first_name.capitalize} #{last_name.capitalize}"
  end

  def full_name_reverse
    "#{last_name.upcase} #{first_name.capitalize}"
  end

  def next_activities
    activities.joins(:camp).where('camps.ends_at > ?', Time.current).order('camps.starts_at')
  end

  def next_annual_activities
    activities.joins(:annual_program).where('annual_programs.ends_at > ?', Time.current).order('annual_programs.starts_at')
  end

  def next_courses
    courses.includes(:activity) # Inclut camp et annual_program
           .where('starts_at > ?', Time.current)
           .order(:starts_at)
  end

  def past_courses
    courses.includes(:activity) # Inclut camp et annual_program
           .where('ends_at < ?', Time.current)
           .order(starts_at: :desc)
  end

  def today_courses
    courses.includes(:activity, :students).where('DATE(starts_at) = ?', Time.current.to_date).order(:starts_at)
  end

  def missing_attendance
    courses.where('ends_at < ?', Time.current).where('status = ?', false)
  end

  # def students
  #   courses.map(&:students).flatten.uniq
  # end

  def academies_ordered
    academies_as_coach.order('coach_academies.created_at')
  end

  private

  def normalize_fields
    self.first_name = first_name.strip.split.map(&:capitalize).join(' ') if first_name.present?
    self.last_name = last_name.strip.split.map(&:capitalize).join(' ') if last_name.present?
    self.email = email.strip.downcase if email.present?
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
