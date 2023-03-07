class Course < ApplicationRecord
  validate :starts_at_before_ends_at

  belongs_to :activity
  has_one :camp, through: :activity
  has_one :school_period, through: :camp
  has_one :academy, through: :school_period

  belongs_to :manager, class_name: 'User', foreign_key: :manager_id
  belongs_to :coach, class_name: 'User', foreign_key: :coach_id

  has_many :course_enrollments, dependent: :destroy
  has_many :students, through: :course_enrollments

  scope :upcoming, ->(time_window) { where('ends_at >= ?', Time.current.in_time_zone('Paris') - time_window) }


  def student_presence(student)
    course_enrollments.find_by(student: student).present
  end

  private

  def starts_at_before_ends_at
    if starts_at.present? && ends_at.present? && starts_at >= ends_at
      errors.add(:starts_at, "L'heure de début doit être avant l'heure de fin")
    end
  end

end
