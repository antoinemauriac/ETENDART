class AnnualProgram < ApplicationRecord

  belongs_to :academy

  has_many :annual_program_enrollments, dependent: :destroy
  has_many :students, through: :annual_program_enrollments

  has_many :program_periods, dependent: :destroy
  has_many :activities, dependent: :destroy
  has_many :categories, -> { distinct }, through: :activities
  has_many :activity_enrollments, through: :activities
  has_many :activity_coaches, through: :activities
  has_many :coaches, -> { distinct }, through: :activity_coaches
  has_many :courses, through: :activities
  has_many :course_enrollments, through: :courses

  has_one :annual_program_stat, dependent: :destroy

  scope :not_full, -> { where("capacity > (SELECT COUNT(*) FROM annual_program_enrollments WHERE annual_program_enrollments.annual_program_id = annual_programs.id AND annual_program_enrollments.confirmed = true)") }
  scope :full, -> { where("capacity <= (SELECT COUNT(*) FROM annual_program_enrollments WHERE annual_program_enrollments.annual_program_id = annual_programs.id AND annual_program_enrollments.confirmed = true)") }

  accepts_nested_attributes_for :program_periods, reject_if: :all_blank, allow_destroy: true
  validate :validate_program_periods
  validate :validate_capacity
  validates :capacity, presence: true

  before_save :set_default_price

  DAY_TO_WDAY = {
    "Dimanche" => 0,
    "Lundi" => 1,
    "Mardi" => 2,
    "Mercredi" => 3,
    "Jeudi" => 4,
    "Vendredi" => 5,
    "Samedi" => 6,
  }

  DAY_NAME_TO_NUMBER = {
    "Sunday" => 0,
    "Monday" => 1,
    "Tuesday" => 2,
    "Wednesday" => 3,
    "Thursday" => 4,
    "Friday" => 5,
    "Saturday" => 6,
    "No day assigned" => 7
  }

  DAY_EN_TO_FR = {
    'Monday' => 'Lundi',
    'Tuesday' => 'Mardi',
    'Wednesday' => 'Mercredi',
    'Thursday' => 'Jeudi',
    'Friday' => 'Vendredi',
    'Saturday' => 'Samedi',
  }

  def can_import?
    program_periods.first.start_date > Time.current
  end

  def ends_at
    program_periods.any? ? program_periods.maximum(:end_date) : Date.current + 10.days
  end

  def current?
    ends_at >= Date.current - 14.days if ends_at
  end

  def today_courses
    courses.includes(:activity).where(starts_at: Time.current.all_day).order(:starts_at)
  end

  def tomorrow_courses
    courses.includes(:activity).where(starts_at: Time.current.tomorrow.all_day).order(:starts_at)
  end

  def started?
    program_periods.minimum(:start_date) <= Date.today
  end

  def name
    "#{starts_at.year} - #{starts_at.year + 1}"
  end

  def short_name
    "#{starts_at.year}/#{starts_at.year + 1}"
  end

  def find_all_specific_days(day_name)
    specific_days = []
    wday = DAY_TO_WDAY[day_name]

    program_periods.each do |period|
      start_date = period.start_date
      end_date = period.end_date

      (start_date..end_date).each do |date|
        specific_days << date if date.wday == wday && date >= Date.current
      end
    end

    specific_days.sort! { |a, b| a <=> b }
    specific_days
  end

  def sorted_activities
    activities.sort_by do |activity|
      [DAY_NAME_TO_NUMBER[activity.day_of_activity], activity.name]
    end
  end

  def active_sorted_activities
    activities.sort_by do |activity|
      [DAY_NAME_TO_NUMBER[activity.day_of_activity], activity.name]
    end
  end

  def week_absent_enrollments_sorted_by_day
    enrollments = course_enrollments.includes([:student, :course, :activity]).where(present: false).where(courses: { starts_at: Time.current.beginning_of_week..Time.current.end_of_week }).distinct

    enrollments.sort_by do |enrollment|
      [DAY_NAME_TO_NUMBER[enrollment.activity.day_of_activity], enrollment.activity.name]
    end
  end

  def past_course_enrollments
    course_enrollments.joins(:course).where('courses.ends_at < ?', Time.current).order('courses.starts_at')
  end

  def students_count
    annual_program_enrollments.confirmed.count
  end

  def confirmed_students
    students.joins(:annual_program_enrollments).where(annual_program_enrollments: { confirmed: true }).distinct
  end

  def available_capacity
    return nil unless capacity&.positive?

    capacity - students_count
  end

  def capacity_full?
    return false unless capacity && capacity > 0
    students_count >= capacity
  end

  def show_students
    students.joins(:annual_program_enrollments).where(annual_program_enrollments: { present: true }).distinct
  end

  def show_count
    show_students.count
  end

  def no_show_count
    students_count - show_count
  end

  def show_rate
    if students_count.positive?
      ((show_count.to_f / students_count) * 100).round(0)
    else
      0
    end
  end

  def no_show_rate
    if students_count.positive?
      ((no_show_count.to_f / students_count) * 100).round(0)
    else
      0
    end
  end

  def enrollments_without_no_show
    course_enrollments.joins(:course)
                      .where("courses.ends_at < ?", Time.current)
                      .where(student_id: show_students).distinct
  end

  def total_enrollments_count
    enrollments_without_no_show.count
  end

  def absent_enrollments_count
    enrollments_without_no_show.unattended.count
  end

  def absenteeism_rate
    if total_enrollments_count.positive?
      ((absent_enrollments_count.to_f / total_enrollments_count) * 100).round(0)
    else
      0
    end
  end

  def number_of_students_by_genre(genre)
    show_students.where(gender: genre).count
  end

  def percentage_of_students_by_genre(genre)
    if show_count.positive?
      genre_students_count = show_students.where(gender: genre).count
      ((genre_students_count.to_f / show_count) * 100).round(0)
    else
      0
    end
  end

  def age_of_students
    (show_students.map(&:age).sum.to_f / show_students.count).round(1)
  end

  def participant_ages
    show_students.map(&:age).uniq.sort
  end

  def number_of_students_by_age(age)
    show_students.count { |student| student.age == age }
  end

  def total_number_of_students(genre)
    show_students.count { |student| student.gender == genre }
  end

  def percentage_of_students(genre)
    if show_count.positive?
      ((total_number_of_students(genre).to_f / show_count) * 100).round(0)
    else
      0
    end
  end

  def participant_departments
    show_students.map(&:department).uniq.sort
  end

  def number_of_students_by_dpt(department)
    show_students.count { |student| student.department == department.to_s }
  end

  def number_of_students_by_category(category)
    activity_enrollments.joins(:activity)
                        .where(activities: { category: category })
                        .count
  end

  def number_of_present_students_by_category(category)
    activity_enrollments.joins(:activity)
                        .where(present: true)
                        .where(activities: { category: category })
                        .count
  end

  def number_of_students_by_category_and_gender(category, gender)
    activity_enrollments.joins(:student, activity: :category)
                        .where(present: true)
                        .where(activities: { category: category }, students: { gender: gender })
                        .count
  end

  def percentage_of_students_by_category_and_gender(category, gender)
    if number_of_present_students_by_category(category).positive?
      ((number_of_students_by_category_and_gender(category, gender).to_f / number_of_present_students_by_category(category)) * 100).round(0)
    else
      0
    end
  end

  def number_of_coaches_by_category(category)
    coaches.joins(:activities)
           .where('activities.category_id = ? AND activities.annual_program_id = ?', category.id, self.id)
           .distinct
           .count
  end

  def absenteeism_rate_by_category(category)
    activities = self.activities.where(category: category)
    total_enrollments_count = activities.sum { |activity| activity.enrollments_without_no_show.count }
    absent_enrollments_count = activities.sum { |activity| activity.absent_enrollments_count }
    if total_enrollments_count.positive?
      ((absent_enrollments_count.to_f / total_enrollments_count) * 100).round(0)
    else
      0
    end
  end

  def format_price
    if paid
      if price == 0
        "Gratuit"
      else
        "#{price}€"
      end
    else
      "Gratuit"
    end
  end

  private

  def validate_program_periods
    program_periods.each do |period|
      unless period.start_date_before_end_date
        errors.add(:base, "Période #{program_periods.index(period) + 1} : la date de début doit être antérieure à la date de fin.")
      end
    end
  end

  def set_default_price
    self.price = 0 if paid == false
  end

  def validate_capacity
    return if capacity.nil? || capacity.zero?

    if capacity < students_count
      errors.add(:capacity, "ne peut pas être inférieure au nombre d'élèves déjà inscrits (#{students_count})")
    end
  end
end
