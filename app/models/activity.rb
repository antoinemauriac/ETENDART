class Activity < ApplicationRecord

  DAYS = {
    Lundi: { start_time: nil, end_time: nil },
    Mardi: { start_time: nil, end_time: nil },
    Mercredi: { start_time: nil, end_time: nil },
    Jeudi: { start_time: nil, end_time: nil },
    Vendredi: { start_time: nil, end_time: nil }
  }

  belongs_to :camp
  has_one :school_period, through: :camp
  has_one :academy, through: :school_period
  belongs_to :category
  # belongs_to :lead_coach, class_name: 'User', foreign_key: :coach_id
  has_many :courses, dependent: :destroy
  has_many :course_enrollments, through: :courses
  accepts_nested_attributes_for :courses

  belongs_to :location

  validates :name, presence: true
  validates :category_id, presence: true
  # validates :coach_id, presence: true

  has_many :activity_enrollments, dependent: :destroy
  has_many :students, through: :activity_enrollments
  # has_many :days
  # accepts_nested_attributes_for :days
  has_many :activity_coaches, dependent: :destroy
  has_many :coaches, through: :activity_coaches, source: :coach

  def lead_coach
    if coach_id.nil?
      "Pas de coach"
    else
      User.find_by(id: coach_id)
    end
  end

  def all_coaches
    coaches << lead_coach
    coaches.uniq
  end

  def banished_students
    students.joins(camp_enrollments: { camp: :activities })
            .where(camp_enrollments: { banished: true }, activities: { id: id })
            .distinct
  end


  # def absenteeism_rate
  #   total_enrollments = course_enrollments.count
  #   absent_enrollments = course_enrollments.where(present: false).count

  #   if total_enrollments.positive?
  #     absenteeism_rate = (absent_enrollments.to_f / total_enrollments) * 100
  #     return absenteeism_rate.round(0)
  #   else
  #     return 0
  #   end
  # end

  def absenteeism_rate
    enrollments = course_enrollments.joins(:course).where("courses.ends_at < ?", Time.current)
    total_enrollments = enrollments.count
    absent_enrollments = enrollments.unattended.count

    if total_enrollments.positive?
      ((absent_enrollments.to_f / total_enrollments) * 100).round(0)
    else
      0
    end
  end

  def number_of_students(genre)
    activity_enrollments.joins(:student).where(students: { gender: genre }).count
  end

  def students_count
    students.count
  end

  # def students
  #   activity_enrollments.map(&:student)
  # end

  def age_of_students
    (students.map(&:age).sum.to_f / students.count).round(1)
  end

  def can_delete?
    if camp.starts_at
      camp.starts_at > Date.today
    else
      true
    end
  end

end
