class Activity < ApplicationRecord

  DAYS = {
    Lundi: { start_time: nil, end_time: nil },
    Mardi: { start_time: nil, end_time: nil },
    Mercredi: { start_time: nil, end_time: nil },
    Jeudi: { start_time: nil, end_time: nil },
    Vendredi: { start_time: nil, end_time: nil }
  }

  has_many :activity_enrollments, dependent: :destroy
  has_many :students, through: :activity_enrollments

  belongs_to :camp, optional: true
  has_one :school_period, through: :camp

  belongs_to :annual_program, optional: true

  belongs_to :category
  belongs_to :location

  belongs_to :coach, class_name: 'User', foreign_key: :coach_id, optional: true
  has_many :activity_coaches, dependent: :destroy
  has_many :coaches, through: :activity_coaches, source: :coach

  has_many :courses, dependent: :destroy
  has_many :course_enrollments, through: :courses
  accepts_nested_attributes_for :courses

  has_one :activity_stat, dependent: :destroy

  validates :name, presence: true
  validates :category_id, presence: true
  validates :location_id, presence: true

  before_save :normalize_name

  # before_save :starts_at_before_ends_at

  def ends_at
    courses.maximum(:ends_at) if courses.any?
  end

  def current?
    ends_at >= Time.current - 1.day if ends_at
  end

  def academy
    return camp.academy if camp
    return annual_program.academy if annual_program
    nil
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

  def enrollments_without_no_show
    course_enrollments.select { |ce| (!ce.student.activity_enrollments.find_by(activity: self, present: true).nil?) && (ce.course.ends_at < Time.current) }
  end

  def absent_enrollments_count
    enrollments_without_no_show.select { |enrollment| !enrollment.present }.count
  end

  def absenteeism_rate
    # enrollments = course_enrollments.joins(course: { student: :activity_enrollments })
                                      # .where("courses.ends_at < ?", Time.current)
                                      # .where("activity_enrollments.present = ?", true)
                                      # .where(student_id: show_students)
    enrollments = course_enrollments.select { |ce| (!ce.student.activity_enrollments.find_by(activity: self, present: true).nil?) && (ce.course.ends_at < Time.current) }

    total_enrollments = enrollments.count
    absent_enrollments = enrollments.select { |enrollment| !enrollment.present }.count

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
    return true unless camp || annual_program
    if camp && camp.starts_at
      camp.starts_at > Date.today
    elsif annual_program && annual_program.program_periods.first
      annual_program.program_periods.first.start_date > Date.today
    else
      true
    end
  end

  # def starts_at_before_ends_at
  #   courses = self.courses
  #   raise
  #   if courses.any?
  #     courses.each do |course|
  #       if course.starts_at >= course.ends_at
  #         errors.add(:base, "L'heure de début doit être avant l'heure de fin")
  #         return false
  #       end
  #     end
  #   else
  #     return true
  #   end
  # end
  private

  def normalize_name
    self.name = name.split.map(&:capitalize).join(' ')
  end
end
