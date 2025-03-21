class Activity < ApplicationRecord

  DAYS = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi']

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
  accepts_nested_attributes_for :courses, allow_destroy: true

  has_one :activity_stat, dependent: :destroy

  validates :name, presence: true
  validates :category_id, presence: true
  validates :location_id, presence: true

  validates :name, uniqueness: { scope: [:camp_id, :annual_program_id], message: "Une activité avec le même nom existe déjà" }

  validates :age_restricted, inclusion: { in: [true, false] }
  validates :min_age, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validates :max_age, numericality: { only_integer: true, greater_than_or_equal_to: 0 }, allow_nil: true
  validate :age_range_valid?

  before_validation :normalize_name

  # before_save :starts_at_before_ends_at

  def ends_at
    courses.any? ? courses.maximum(:ends_at) : Date.current + 10.days
  end

  def current?
    ends_at >= Time.current - 7.days if ends_at
  end

  # def starts_time
  #   if courses.any?
  #     start_time = courses.first.starts_at
  #     start_time.min.zero? ? start_time.strftime("%Hh") : start_time.strftime("%Hh%M")
  #   else
  #     "00:00"
  #   end
  # end

  def hour_range
    if courses.any?
      start_time = courses.first.starts_at
      end_time = courses.first.ends_at
      start_time_str = start_time.min.zero? ? start_time.strftime("%Hh") : start_time.strftime("%Hh%M")
      end_time_str = end_time.min.zero? ? end_time.strftime("%Hh") : end_time.strftime("%Hh%M")
      "#{start_time_str} - #{end_time_str}"
    else
      "00:00 - 00:00"
    end
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

  private

  def age_range_valid?
    return unless age_restricted
  
    if min_age.nil?
      errors.add(:min_age, "doit être renseigné")
    end
  
    if max_age.nil?
      errors.add(:max_age, "doit être renseigné")
    end
  
    if min_age.present? && max_age.present? && min_age > max_age
      errors.add(:base, "L'âge minimum ne peut pas être supérieur à l'âge maximum.")
    end
  end

  def normalize_name
    self.name = name.split.map(&:capitalize).join(' ')
  end
end
