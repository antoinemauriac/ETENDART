class Activity < ApplicationRecord

  DAYS = {
    Lundi: { start_time: nil, end_time: nil },
    Mardi: { start_time: nil, end_time: nil },
    Mercredi: { start_time: nil, end_time: nil },
    Jeudi: { start_time: nil, end_time: nil },
    Vendredi: { start_time: nil, end_time: nil }
  }

  belongs_to :camp, optional: true
  belongs_to :coach, class_name: 'User', foreign_key: :coach_id, optional: true
  has_one :school_period, through: :camp
  # has_one :academy, through: :school_period

  belongs_to :annual_program, optional: true

  belongs_to :category
  # belongs_to :lead_coach, class_name: 'User', foreign_key: :coach_id
  has_many :courses, dependent: :destroy
  has_many :course_enrollments, through: :courses
  accepts_nested_attributes_for :courses

  belongs_to :location

  validates :name, presence: true
  validates :category_id, presence: true
  validates :location_id, presence: true
  # validates :coach_id, presence: true

  has_many :activity_enrollments, dependent: :destroy
  has_many :students, through: :activity_enrollments
  # has_many :days

  has_many :activity_coaches, dependent: :destroy
  has_many :coaches, through: :activity_coaches, source: :coach

  def academy
    if camp
      camp.academy
    elsif annual_program
      annual_program.academy
    else
      nil
    end
  end

  def lead_coach
    User.find_by(id: coach_id) if coach_id
  end

  def all_coaches
    coaches << lead_coach if lead_coach
    coaches.uniq
  end

  def day_of_activity
    first_course = courses.first
    return "No day assigned" unless first_course&.starts_at

    first_course.starts_at.strftime("%A")
  end

  def next_courses
    courses.where("starts_at > ?", Time.current).order(:starts_at)
  end

  def banished_students
    students.joins(camp_enrollments: { camp: :activities })
            .where(camp_enrollments: { banished: true }, activities: { id: id })
            .distinct
  end

  def absenteeism_rate
    enrollments = course_enrollments.joins(course: { activity: :activity_enrollments })
                                    .where("courses.ends_at < ?", Time.current)
                                    .where("activity_enrollments.present = ?", true)
    total_enrollments = enrollments.count
    absent_enrollments = enrollments.unattended.count

    if total_enrollments.positive?
      ((absent_enrollments.to_f / total_enrollments) * 100).round(0)
    else
      0
    end
  end

  def show_students
    students.joins(:activity_enrollments).where(activity_enrollments: { present: true }).distinct
  end

  def no_show_students
    students - show_students
  end

  def number_of_students_by_genre(genre)
    show_students.where(gender: genre).count
  end

  def students_count
    show_students.count
  end

  def age_of_students
    (show_students.map(&:age).sum.to_f / students_count).round(1)
  end

  def can_delete?
    if camp
      if camp.starts_at
        camp.starts_at > Date.today
      else
        true
      end
    elsif annual_program
      if annual_program.program_periods.first.start_date
        annual_program.program_periods.first.start_date > Date.today
      else
        true
      end
    else
      true
    end
  end
end
