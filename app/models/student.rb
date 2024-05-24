class Student < ApplicationRecord
  include PgSearch::Model

  pg_search_scope :search_by_query, against: [:first_name, :last_name, :gender, :email, :phone_number, :city],
    using: {
      tsearch: { prefix: true }
    }

  validates :username, :first_name, :last_name, :date_of_birth, :gender, presence: true

  DEFAULT_AVATAR = "xkhgd88iqzlk5ctay2hu.png"

  scope :today_birthday, -> { where('EXTRACT(month FROM date_of_birth) = ? AND EXTRACT(day FROM date_of_birth) = ?', Date.today.month, Date.today.day).order("created_at DESC") }

  attr_accessor :academy1_id, :academy2_id, :academy3_id

  has_one_attached :photo

  has_many :memberships, dependent: :destroy

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

  has_many :annual_program_enrollments, dependent: :destroy
  has_many :annual_programs, through: :annual_program_enrollments

  before_validation :normalize_fields, :normalize_phone_number

  def full_name
    "#{first_name} #{last_name}"
  end

  def full_name_separator
    "#{last_name.upcase} - #{first_name}"
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
                      .where('courses.ends_at < ?', Time.current)
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

  def past_courses_count(activity = nil)
    if activity
      courses.where('ends_at < ? AND activity_id = ?', Time.current, activity.id).count
    else
      courses.where('ends_at < ?', Time.current).count
    end
  end

  def unattended_courses_count(options = { camp: nil, activity: nil })
    activity = options[:activity] if options.present?
    camp = options[:camp] if options.present?

    if activity
      course_enrollments.unattended.joins(:course)
                        .where('ends_at < ? AND activity_id = ?', Time.current, activity.id)
                        .count
    elsif camp
      course_enrollments.unattended.joins(course: :camp)
                        .where('courses.ends_at < ?', Time.current)
                        .where('camps.id = ?', camp.id)
                        .count
    else
      course_enrollments.unattended.joins(:course)
                        .where('courses.ends_at < ?', Time.current)
                        .count
    end
  end

  def unattended_activity_rate(activity = nil)
    return "" if activity.nil?
    past_count = past_courses_count(activity)
    unattended_count = unattended_courses_count(activity: activity)

    if past_count.positive?
      (unattended_count.to_f / past_count * 100).round
    else
      0
    end
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

  def annual_programs_count
    annual_programs.count
  end

  def student_activities(camp)
    activities.where(camp: camp).order(name: :desc)
  end

  def student_activities_without_acc(camp)
    activities.where.not(category: Category.find_by(name: "Accompagnement")).where(camp: camp).order(name: :desc)
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

  def department
    if zipcode
      zipcode.to_s.first(2)
    else
      "No zipcode"
    end
  end

  def active_camps
    Camp.joins(:camp_enrollments)
        .where(camp_enrollments: { banished: false, student_id: id })
  end

  def next_courses_by_activity(activity)
    courses.where('starts_at > ?', Time.current)
            .where(activity_id: activity.id)
            .order(starts_at: :asc)
  end

  def next_camp_activities
    activities.joins(:camp).merge(active_camps)
              .where('camps.ends_at > ?', Time.current)
              .order('camps.starts_at ASC')
  end

  def next_annual_activities
    activities.joins(:annual_program)
              .where('annual_programs.ends_at >= ?', Date.current)
  end

  def first_academy
    academies.first
  end

  def main_academy
    # # Collecter tous les cours et leurs académies associées
    # academy_counts = courses.each_with_object(Hash.new(0)) do |course, counts|
    #   # Déterminer si le cours appartient à un camp ou à un programme annuel
    #   academy = if course.activity.camp
    #               course.activity.camp.school_period.academy
    #             else
    #               course.activity.annual_program.academy
    #             end
    #   counts[academy] += 1
    # end

    # # Trouver l'académie avec le nombre maximum de cours
    # primary_academy = academy_counts.max_by { |_academy, count| count }&.first

    # # Renvoyer la première académie si la principale est nil
    # primary_academy || academies.first
    courses.order(:starts_at)&.last&.academy || academies.first
  end

  def predominant_sport
    category_counts = courses.joins(activity: :category).group('categories.name').count
    tennis_count = category_counts['Tennis'] || 0
    judo_count = category_counts['Judo'] || 0
    basket_count = category_counts['Basket'] || 0
    football_count = category_counts['Football'] || 0
    handball_count = category_counts['Handball'] || 0

    counts = {
      'Tennis' => tennis_count,
      'Judo' => judo_count,
      'Basket' => basket_count,
      'Football' => football_count,
      'Handball' => handball_count
    }

    # Vérifier si tous les compteurs sont à zéro
    return '' if counts.values.all?(&:zero?)

    predominant_sport = counts.max_by { |_, count| count }[0]
    predominant_sport
  end

  def self.with_at_least_one_course(start_year)
    start_date = Date.new(start_year, 4, 7)

    joins(courses: { activity: :camp }) # Ajout de la jointure avec activity et camp
      .where('courses.starts_at > ?', start_date)
      .where(course_enrollments: { present: true })
      .where.not(camps: { id: nil }) # Filtrer les cours avec un camp non nul
      .group('students.id') # Ajout de la group_by pour éviter les doublons
      .pluck(:id)
  end


  def photo_or_default
    if photo.attached?
      photo.key
    else
      DEFAULT_AVATAR
    end
  end

  def last_attended_course_date
    course_enrollments
      .where(present: true)
      .joins(:course)
      .where('courses.ends_at < ?', Time.current)
      .order('courses.ends_at DESC')
      .limit(1)
      .pluck('courses.ends_at')
      .first
  end

  private

  def normalize_fields
    self.username = username.strip.downcase.gsub(/\s+/, '') if username.present?
    self.first_name = first_name.strip.split.map(&:capitalize).join(' ') if first_name.present?
    self.last_name = last_name.strip.split.map(&:capitalize).join(' ') if last_name.present?
    self.email = email.strip.downcase if email.present?
    self.city = city.strip.split.map(&:capitalize).join(' ') if city.present?
    self.address = address.strip.split.map(&:capitalize).join(' ') if address.present?
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
