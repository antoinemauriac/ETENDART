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

  validates :name, uniqueness: { scope: [:camp_id, :annual_program_id], message: "Une activité avec le même nom existe déjà" }

  before_validation :normalize_name

  # before_save :starts_at_before_ends_at

  def ends_at
    courses.any? ? courses.maximum(:ends_at) : Date.current + 10.days
  end

  def current?
    ends_at >= Time.current - 7.days if ends_at
  end

  def academy
    return camp.academy if camp
    return annual_program.academy if annual_program
    nil
  end

  def day_of_activity
    last_course = courses.last
    return "No day assigned" unless last_course&.starts_at

    last_course.starts_at.strftime("%A")
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
    if camp.present?
      show_students = camp.show_students
    elsif annual_program.present?
      show_students = annual_program.show_students
    end
    # course_enrollments.select { |ce| (!ce.student.activity_enrollments.find_by(activity: self, present: true).nil?) && (ce.course.ends_at < Time.current) }
    course_enrollments.select { |ce| show_students.include?(ce.student) && ce.course.ends_at < Time.current }
  end

  def absent_enrollments_count
    enrollments_without_no_show.select { |enrollment| !enrollment.present }.count
  end

  def absenteeism_rate
    if camp.present?
      show_students = camp.show_students
    elsif annual_program.present?
      show_students = annual_program.show_students
    end
    # enrollments = course_enrollments.select { |ce| (!ce.student.activity_enrollments.find_by(activity: self, present: true).nil?) && (ce.course.ends_at < Time.current) }
    enrollments = course_enrollments.select { |ce| show_students.include?(ce.student) && ce.course.ends_at < Time.current }

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

  def enrolled_students_count
    students.count
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
