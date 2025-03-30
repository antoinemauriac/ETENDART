class Student < ApplicationRecord
  include PgSearch::Model

  pg_search_scope :search_by_query, against: [:first_name, :last_name, :gender, :email, :phone_number, :city],
    using: {
      tsearch: { prefix: true }
    }

    # t.string "username"
    # t.string "first_name"
    # t.string "last_name"
    # t.date "date_of_birth"
    # t.string "gender"
    # t.string "email"
    # t.string "address"
    # t.datetime "created_at", null: false
    # t.datetime "updated_at", null: false
    # t.string "phone_number"
    # t.string "city"
    # t.integer "zipcode"
    # t.string "allergy"
    # t.integer "number_of_tshirts", default: 0
    # t.bigint "user_id"
    # t.integer "siblings_count", default: 0, null: false
    # t.string "school"
    # t.boolean "rules_signed", default: false, null: false
    # t.boolean "has_medical_treatment", default: false, null: false
    # t.text "medical_treatment_description"
    # t.boolean "has_consent_for_photos", default: false
    # t.index ["user_id"], name: "index_students_on_user_id"

  validates :username, :first_name, :last_name, :date_of_birth, :gender, presence: true



  DEFAULT_AVATAR = "xkhgd88iqzlk5ctay2hu.png"

  scope :today_birthday, -> { where('EXTRACT(month FROM date_of_birth) = ? AND EXTRACT(day FROM date_of_birth) = ?', Date.today.month, Date.today.day).order("created_at DESC") }

  attr_accessor :academy1_id, :academy2_id, :academy3_id

  has_one_attached :photo

  belongs_to :parent, class_name: 'User', foreign_key: 'user_id', optional: true

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

  # after_create :must_pay_membership

  # after_update :must_pay_membership, if: :saved_change_to_user_id?

  ##############################################################################
  # GESTION DES INFORMATION DE L'ENFANT
  ##############################################################################

  def any_lack_of_infos?
    address.blank? || zipcode.blank? || city.blank? || has_medical_treatment.nil? || has_consent_for_photos.nil? || rules_signed.nil? || (has_medical_treatment && medical_treatment_description.blank?) || school.blank?
  end




  ##############################################################################


  ##############################################################################
  # GESTION DES ENFANTS AVEC ET SANS PARENT
  ##############################################################################

  # Tous les students avec parent
  def self.with_parent
    where.not(parent: nil)
  end

  # Tous les students sans parent
  def self.no_parent
    where(parent_id: nil)
  end

  ##############################################################################


  ##############################################################################
  # GESTION DES ENROLLMENTS
  ##############################################################################

  # VRAI si il est enrollé dans une school_period
  def is_enrolled_in_school_period?(school_period)
    return true if school_period_enrollments.find_by(school_period_id: school_period.id)
  end

  # VRAI si il est enrollé dans un camp
  def is_enrolled_in_camp?(camp)
    return true if camp_enrollments.find_by(camp_id: camp.id)
  end

  # VRAI si il est enrollé dans un autre camp de la même school_period
  def is_enrolled_in_other_camps?(camp)
    school_period = camp.school_period
    school_period.camps.where.not(id: camp.id).each do |c|
      return true if is_enrolled_in_camp?(c)
    end
    return false
  end

  # VRAI si il a payé un camp
  def has_paid_camp?(camp)
    return true if camp_enrollments.find_by(camp_id: camp.id, paid: true)
  end

  # renvoie VRAI si l'étudiant est inscrit à une activité précise
  def is_enrolled_in_activity?(activity)
    activity_enrollments.exists?(activity_id: activity.id)
  end

  # VRAI si il est dans une autre activité du même camp
  def is_enrolled_in_other_activities?(activity)
    camp = activity.camp
    camp.activities.where.not(id: activity.id).each do |act|
      return true if is_enrolled_in_activity?(act)
    end
    return false
  end



  ##############################################################################


  ##############################################################################
  # GESTION DES COTISATIONS POUR UN ENFANT
  ##############################################################################

  # la cotisation
  def membership?(start_year)
    return memberships.find_by(start_year: start_year).present?
  end

  # return la cotisation de cette année, payée ou non.
  def current_membership
    start_year = Date.current.month >= 9 ? Date.current.year : Date.current.year - 1
    return memberships.find_by(start_year: start_year)
  end

  # la cotisation n'est pas payée
  def membership_not_paid?
    start_year = Date.current.month >= 9 ? Date.current.year : Date.current.year - 1
    return memberships.find_by(start_year: start_year, paid: false).present?
  end

  # les étudiants qui obtiennent un parent créent automatiquement un cart_item avec le membership s'il n'est pas adhérent
  def must_pay_membership
    # est ce qu'il y a une adhésion pour l'année en cours ?
    start_year = Date.current.month >= 9 ? Date.current.year : Date.current.year - 1
    if membership_not_paid? || memberships.find_by(start_year: start_year).nil?
      membership = self.memberships.find_or_create_by(start_year: start_year, amount: Membership::PRICE, stripe_price_id: "price_1R7fTuFQepXQSK7Ty0jfdwvI")
      cart = self.parent.pending_cart
      cart_name = "Adhésion #{membership.start_year}/#{membership.start_year + 1} - #{self.first_name} #{self.last_name}"
      cart_item = cart.cart_items.create!(product: membership, price: 15.00, student: self, stripe_price_id: "price_1R7fTuFQepXQSK7Ty0jfdwvI", name: cart_name)
    end
  end

  ##############################################################################

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
      course_enrollments.includes(:activity).unattended.joins(:course)
                        .where('ends_at < ? AND activity_id = ?', Time.current, activity.id)
                        .count
    elsif camp
      course_enrollments.includes(:activity, :camp).unattended.joins(course: :camp)
                        .where('courses.ends_at < ?', Time.current)
                        .where('camps.id = ?', camp.id)
                        .count
    else
      course_enrollments.includes(:course).unattended.joins(:course)
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
    camp_enrollments.confirmed.count
  end

  def annual_programs_count
    annual_programs.count
  end

  def student_activities(camp)
    activities.where(camp: camp).order(name: :desc)
  end

  def present_during_activity?(activity, course)
    course_enrollments.joins(:course)
                      .where(course: activity.courses)
                      .where('courses.ends_at < ?', course.ends_at)
                      .where(present: true)
                      .any?
  end

  def present_during_camp?(camp, course)
    course_enrollments.joins(:course)
                      .where(course: camp.courses)
                      .where('courses.ends_at < ?', course.ends_at)
                      .where(present: true)
                      .any?
  end

  def present_during_school_period?(school_period, course)
    course_enrollments.joins(:course)
                      .where(course: school_period.courses)
                      .where('courses.ends_at < ?', course.ends_at)
                      .where(present: true)
                      .any?
  end

  def present_during_annual_program?(annual_program, course)
    course_enrollments.joins(:course)
                      .where(course: annual_program.courses)
                      .where('courses.ends_at < ?', course.ends_at)
                      .where(present: true)
                      .any?
  end

  def student_activities_without_acc(camp)
    activities.where(camp: camp)
              .where.not(category: Category.find_by(name: "Accompagnement"))
              .left_joins(:courses)
              .group('activities.id')
              .order('COUNT(courses.id) DESC, activities.name DESC')
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

  def next_courses_by_activity(activity)
    courses.where('starts_at > ?', Time.current)
            .where(activity_id: activity.id)
            .order(starts_at: :asc)
  end

  def next_camp_activities
    activities.joins(:camp, :activity_enrollments)
              .where(activity_enrollments: { confirmed: true })
              .where('camps.ends_at >= ?', Date.current)
              .order('camps.starts_at ASC')
  end

  def next_annual_activities
    activities.joins(:annual_program)
              .where('annual_programs.ends_at >= ?', Date.current)
  end

  def first_academy
    academies&.first
  end

  def today_course
    courses.where('DATE(starts_at) = ?', Date.current)
           .order(starts_at: :asc)
           .first
  end

  def next_course
    courses.where('starts_at >= ?', Date.current - 1.day)
           .order(starts_at: :asc)
           .first
  end

  def last_course_before_today
    courses.where('ends_at <= ?', Date.current + 1.day)
           .order(starts_at: :desc)
           .first
  end

  def membership_academy
    if today_course.present?
      today_course.academy
    elsif next_course.present?
      next_course.academy
    elsif last_course_before_today.present?
      last_course_before_today.academy
    else
      academies.first
    end
  end

  def main_academy
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
    end_date = Date.current

    joins(:courses)
      .where('courses.starts_at > ? AND courses.ends_at <= ?', start_date, end_date)
      .where(course_enrollments: { present: true })
      .group('students.id')
      .pluck(:id)
  end

  def courses_count_during_period
    course_enrollments.where(present: true).joins(:course).where('courses.starts_at > ? AND courses.ends_at <= ?', Date.new(2024, 4, 7), Date.today).count
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

  def payable_camp_enrollments
    free_judo_camp_ids = fetch_free_judo_camp_ids

    attended_camps = fetch_attended_camps(free_judo_camp_ids)
    unattended_camps = fetch_unattended_upcoming_camps(free_judo_camp_ids)

    attended_camps.or(unattended_camps).order('camps.starts_at DESC')
  end

  private

  def fetch_free_judo_camp_ids
    activities.joins(:category, camp: :school_period, activity_enrollments: :student)
              .where(categories: { name: 'Judo' }, school_periods: { paid: true, free_judo: true }, activity_enrollments: { confirmed: true })
              .pluck('camps.id')
  end

  def fetch_attended_camps(free_judo_camp_ids)
    camp_enrollments.confirmed
                    .attended
                    .joins(camp: :school_period)
                    .where.not(camp_id: free_judo_camp_ids)
                    .where(school_periods: { paid: true })
                    .includes(camp: [:school_period, :academy])
  end

  def fetch_unattended_upcoming_camps(free_judo_camp_ids)
    camp_enrollments.confirmed
                    .unattended
                    .joins(camp: :school_period)
                    .where(school_periods: { paid: true })
                    .where('camps.ends_at > ?', Time.current)
                    .includes(camp: [:school_period, :academy])
  end

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
