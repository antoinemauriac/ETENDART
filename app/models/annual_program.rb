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

  def ends_at
    program_periods.maximum(:end_date)
  end

  def current?
    ends_at >= Date.current - 1.day if ends_at
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

  def old_presence_sheet
    courses.includes(:activity).where('courses.ends_at < ?', Time.current).where(status: false).order(:starts_at)
  end

  def students_count
    students.count
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
    if number_of_students_by_category(category).positive?
      ((number_of_students_by_category_and_gender(category, gender).to_f / number_of_students_by_category(category)) * 100).round(0)
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

  private

  def validate_program_periods
    program_periods.each do |period|
      unless period.start_date_before_end_date
        errors.add(:base, "Période #{program_periods.index(period) + 1} : la date de début doit être antérieure à la date de fin.")
      end
    end
  end
end

  # annual_program = AnnualProgram.first
  # annual_program_stat = annual_program.annual_program_stat
  # annual_program_stat.students_count = annual_program.students_count
  # annual_program_stat.coaches_count = annual_program.coaches.uniq.count
  # annual_program_stat.show_count = annual_program.show_count
  # annual_program_stat.no_show_count = annual_program.no_show_count
  # annual_program_stat.show_rate = annual_program.show_rate
  # annual_program_stat.no_show_rate = annual_program.no_show_rate
  # annual_program_stat.absenteeism_rate = annual_program.absenteeism_rate

  # annual_program_stat.percentage_of_boy = annual_program.percentage_of_students("Garçon")
  # annual_program_stat.percentage_of_girl = annual_program.percentage_of_students("Fille")


  # annual_program_stat.age_of_students = annual_program.age_of_students

  # annual_program_stat.participant_ages = annual_program.participant_ages

  # annual_program_stat.participant_ages.each do |age|
  #   annual_program_stat.student_count_by_age[age] = annual_program.number_of_students_by_age(age)
  # end

  # annual_program_stat.participant_departments = annual_program.participant_departments.sort_by do |department|
  #   -annual_program.number_of_students_by_dpt(department)
  # end

  # annual_program_stat.participant_departments.each do |department|
  #   annual_program_stat.student_count_by_department[department] = annual_program.number_of_students_by_dpt(department)
  # end

  # annual_program_stat.category_ids = annual_program.categories.includes(:activities).uniq.sort_by do |category|
  #   annual_program.number_of_students_by_category(category)
  # end.reverse.pluck(:id)

  # annual_program_stat.category_ids.each do |id|
  #   annual_program_stat.students_count_by_category[id] = annual_program.number_of_students_by_category(Category.find(id))
  #   annual_program_stat.percentage_of_boy_by_category[id] = annual_program.percentage_of_students_by_category_and_gender(Category.find(id), "Garçon")
  #   annual_program_stat.percentage_of_girl_by_category[id] = annual_program.percentage_of_students_by_category_and_gender(Category.find(id), "Fille")
  #   annual_program_stat.absenteisme_rate_by_category[id] = annual_program.absenteeism_rate_by_category(Category.find(id))
  #   annual_program_stat.number_of_coaches_by_category[id] = annual_program.number_of_coaches_by_category(Category.find(id))
  # end

  # annual_program_stat.save
