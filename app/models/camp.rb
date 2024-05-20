class Camp < ApplicationRecord
  belongs_to :school_period
  has_one :academy, through: :school_period

  has_many :camp_enrollments, dependent: :destroy
  has_many :students, through: :camp_enrollments

  has_many :activities, dependent: :destroy
  has_many :activity_coaches, through: :activities

  has_many :activity_enrollments, through: :activities

  has_many :courses, through: :activities
  has_many :course_enrollments, through: :courses

  has_many :coach_camps, dependent: :destroy
  has_many :coaches, through: :coach_camps, source: :coach

  has_one :camp_stat, dependent: :destroy

  validates :name, presence: true
  validates :starts_at, presence: true
  validates :ends_at, presence: true

  validate :starts_at_must_be_before_ends_at
  validates :name, uniqueness: { scope: [:school_period_id], message: "Une semaine avec le même nom existe déjà pour ce stage" }

  def current?
    ends_at >= Time.current - 7.days
  end

  def banished_students
    students.joins(:camp_enrollments).where(camp_enrollments: { banished: true }).uniq
  end

  def students_count
    students.count
  end

  def show_students
    students.joins(:camp_enrollments).where(camp_enrollments: { present: true }).distinct
  end

  def show_count
    show_students.count
  end

  def no_show_students
    students - show_students
  end

  def no_show_count
    no_show_students.count
  end

  def no_show_rate
    if students_count.positive?
      ((no_show_count.to_f / students_count) * 100).round(0)
    else
      0
    end
  end

  def show_rate
    if students_count.positive?
      ((show_count.to_f / students_count) * 100).round(0)
    else
      0
    end
  end

  def number_of_students_by_genre(genre)
    camp_enrollments.joins(:student).where(students: { gender: genre }).count
  end

  def percentage_of_students_by_genre(genre)
    if show_count.positive?
      genre_students_count = show_students.where(gender: genre).count
      ((genre_students_count.to_f / show_count) * 100).round(0)
    else
      0
    end
  end

  def can_import?
    if starts_at
      starts_at > Date.today
    else
      true
    end
  end

  def started?
    starts_at <= Date.today
  end

  def age_of_students
    (show_students.map(&:age).sum.to_f / show_students.count).round(1)
  end

  def participant_ages
    show_students.map(&:age).uniq.sort
  end

  def participant_departments
    show_students.map(&:department).uniq.sort
  end

  def number_of_students_by_age(age)
    show_students.count { |student| student.age == age }
  end

  def number_of_students_by_dpt(department)
    show_students.count { |student| student.department == department.to_s }
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

  def enrollments_without_no_show_by_category(category)
    enrollments_without_no_show.joins(course: { activity: :category })
                               .where("categories.id" => category.id)
  end

  def total_enrollments_count_by_category(category)
    enrollments_without_no_show_by_category(category).count
  end

  def absent_enrollments_count_by_category(category)
    enrollments_without_no_show_by_category(category).unattended.count
  end

  def new_students_count
    show_students.select { |student| student.camps.where('starts_at < ?', starts_at).empty? }.count
  end

  def new_students_rate
    if show_count.positive?
      ((new_students_count.to_f / show_count) * 100).round(0)
    else
      0
    end
  end

  def expected_revenue
    show_count * school_period.price
  end

  def received_revenue
    camp_enrollments.where(has_paid: true).count * school_period.price
  end

  def missing_revenue
    expected_revenue - received_revenue
  end

  def student_without_tennis
    tennis_activity_ids = self.activities.joins(:category).where(categories: { name: 'Tennis' }).pluck(:id)
    show_students.select { |student| student.courses.where(activity_id: tennis_activity_ids).empty? }
  end

  def missing_clarisse_revenue
    student_without_tennis.count * school_period.price
  end

  private

  def starts_at_must_be_before_ends_at
    errors.add(:starts_at, :after) if starts_at >= ends_at
  end
end
