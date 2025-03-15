class Academy < ApplicationRecord
  has_one_attached :image

  has_many :memberships
  has_many :locations
  has_many :school_periods

  has_many :camps, through: :school_periods
  has_many :activities_through_camps, through: :camps, source: :activities
  has_many :courses_through_camps, through: :activities_through_camps, source: :courses

  has_many :annual_programs
  has_many :activities_through_annual_programs, through: :annual_programs, source: :activities
  has_many :courses_through_annual_programs, through: :activities_through_annual_programs, source: :courses


  belongs_to :manager, class_name: 'User'
  belongs_to :coordinator, class_name: 'User', optional: true
  has_many :coach_academies
  has_many :coaches, through: :coach_academies

  has_many :academy_enrollments
  has_many :students, through: :academy_enrollments

  def today_camp_courses
    Course.joins(activity: :camp)
          .where(camps: { id: camps.ids })
          .where(starts_at: Time.current.all_day)
          .order(:starts_at)
  end

  def today_annual_courses
    Course.joins(:annual_program)
          .where(annual_programs: { id: annual_programs.ids })
          .where(starts_at: Time.current.all_day)
          .order(:starts_at)
  end

  def tomorrow_camp_courses
    Course.joins(activity: :camp)
          .where(camps: { id: camps.ids })
          .where(starts_at: Time.current.tomorrow.all_day)
          .order(:starts_at)
  end

  def tomorrow_annual_courses
    Course.joins(:annual_program)
          .where(annual_programs: { id: annual_programs.ids })
          .where(starts_at: Time.current.tomorrow.all_day)
          .order(:starts_at)
  end

  # def today_courses
  #   (today_camp_courses + today_annual_courses).order(:starts_at)
  # end
  def today_courses
    Course.where(id: (today_camp_courses.ids + today_annual_courses.ids).uniq)
          .includes(activity: :coach)
          .order(:starts_at)
  end

  # def tomorrow_courses
  #   (tomorrow_camp_courses + tomorrow_annual_courses).sort_by(&:starts_at)
  # end
  def tomorrow_courses
    courses.includes(activity: :coach).where(starts_at: Time.current.tomorrow.all_day).order(:starts_at)
  end

  def today_absent_students
    students.joins(courses: :course_enrollments)
            .where(course_enrollments: { present: false })
            .where(courses: { starts_at: Time.current.all_day })
            .distinct
            .order(:last_name)
  end

  def old_presence_sheet
    courses.includes(:activity).where('courses.ends_at < ?', Time.current).where(status: false).order(:starts_at)
  end

  def image_url
    if image.attached?
      cl_image_path(self.image.key, quality: :auto)
    else
      ActionController::Base.helpers.asset_path('home.jpg')
    end
  end

  def courses
    Course.where(id: (courses_through_camps.ids + courses_through_annual_programs.ids).uniq)
  end

  def next_school_periods
    school_periods.select { |school_period| !school_period.ended? }
  end

  def short_name
    name.split(' ').first(2).join(' ').upcase
  end
end
