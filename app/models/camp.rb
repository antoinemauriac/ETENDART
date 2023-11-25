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

  validates :name, presence: true
  validate :starts_at_must_be_before_ends_at

  scope :banished, -> { where(banished: true) }


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

  def number_of_students_by_age(age)
    show_students.count { |student| student.age == age }
  end

  def number_of_students_by_dpt(department)
    show_students.count { |student| student.department == department }
  end

  def enrollments_without_no_show
    course_enrollments.joins(course: { activity: :category })
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

  def coaches
    activity_coaches.map(&:coach).uniq
  end

  def coaches_count
    coaches.count
  end

  def coaches_by_gender(genre)
    coaches.select { |coach| coach.gender == genre }
  end

  private

  def starts_at_must_be_before_ends_at
    errors.add(:starts_at, :after) if starts_at >= ends_at
  end
end
