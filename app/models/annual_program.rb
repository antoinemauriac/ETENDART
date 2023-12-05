class AnnualProgram < ApplicationRecord

  belongs_to :academy

  has_many :annual_program_enrollments, dependent: :destroy
  has_many :students, through: :annual_program_enrollments

  has_many :program_periods, dependent: :destroy
  has_many :activities, dependent: :destroy
  has_many :activity_enrollments, through: :activities
  has_many :activity_coaches, through: :activities
  has_many :coaches, -> { distinct }, through: :activity_coaches
  has_many :courses, through: :activities
  has_many :course_enrollments, through: :courses

  accepts_nested_attributes_for :program_periods, reject_if: :all_blank, allow_destroy: true
  validate :validate_program_periods


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

  def can_import?
    program_periods.first.start_date > Time.current
  end

  def today_courses
    courses.includes(:activity).where(starts_at: Time.current.all_day).order(:starts_at)
  end

  def tomorrow_courses
    courses.includes(:activity).where(starts_at: Time.current.tomorrow.all_day).order(:starts_at)
  end

  def started?
    program_periods.first.start_date <= Date.today
  end

  def name
    "#{starts_at.year} - #{starts_at.year + 1}"
  end

  def find_all_specific_days(day_name)
    specific_days = []
    wday = DAY_TO_WDAY[day_name]

    program_periods.each do |period|
      start_date = period.start_date
      end_date = period.end_date

      (start_date..end_date).each do |date|
        specific_days << date if date.wday == wday
      end
    end

    specific_days.sort! { |a, b| a <=> b }
    specific_days
  end

  def sorted_activities
    activities.sort_by do |activity|
      DAY_NAME_TO_NUMBER[activity.day_of_activity]
    end
  end

  def week_absent_enrollments_sorted_by_day
    enrollments = course_enrollments.where(present: false).where(courses: { starts_at: Time.current.beginning_of_week..Time.current.end_of_week }).distinct

    enrollments.sort_by do |enrollment|
      [DAY_NAME_TO_NUMBER[enrollment.activity.day_of_activity], enrollment.activity.name]
    end
  end

  def past_course_enrollments
    course_enrollments.joins(:course).where('courses.ends_at < ?', Time.current).order('courses.starts_at')
  end

  private

  def validate_program_periods
    program_periods.each do |period|
      unless period.start_date_before_end_date
        errors.add(:base, "Période #{program_periods.index(period) + 1} : la date de début doit être antérieure à la date de fin.")
      end
    end
  end
end
