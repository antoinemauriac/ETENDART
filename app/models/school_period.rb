class SchoolPeriod < ApplicationRecord

  MESSAGE = "Avant de valider, avez vous-vérifier que les dates des camps sont correctes ?"

  belongs_to :academy
  has_many :camps, dependent: :destroy
  has_many :coaches, through: :camps
  has_many :camp_enrollments, through: :camps
  has_many :students, through: :camp_enrollments

  has_many :old_camp_deposits, through: :camps
  has_many :camp_deposits, through: :camps
  has_many :students, through: :camp_enrollments

  has_many :activities, through: :camps
  has_many :activity_enrollments, through: :activities
  has_many :categories, -> { distinct }, through: :activities
  has_many :courses, through: :activities
  has_many :course_enrollments, through: :courses

  has_many :school_period_enrollments, dependent: :destroy

  has_one :school_period_stat, dependent: :destroy

  validates :name, uniqueness: { scope: [:year, :academy_id], message: "Un stage avec le même nom et la même année existe déjà pour cette académie." }
  validates :name, inclusion: { in: %w[Février Printemps Été Toussaint], message: "Le nom du stage doit être Automne, Hiver, Printemps ou Été." }

  before_validation :normalize_name
  before_save :set_default_price


  def full_name
    "#{name} - #{year}"
  end

  def students_count
    students.count
  end

  def show_students_ids
    camps.map(&:show_students).flatten.pluck(:id)
  end

  def show_students
    show_students_ids.map { |student_id| Student.find(student_id) }
  end

  def show_count
    # camps.sum(&:show_count)
    camp_enrollments.attended.count
  end

  def show_rate
    if students_count.positive?
      ((show_count.to_f / students_count) * 100).round(0)
    else
      0
    end
  end

  def no_show_count
    camps.sum(&:no_show_count)
  end

  def no_show_rate
    if students_count.positive?
      ((no_show_count.to_f / students_count) * 100).round(0)
    else
      0
    end
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

  def age_of_students
    (show_students.map(&:age).sum.to_f / show_count).round(1)
  end

  def participant_ages
    show_students.map(&:age).uniq.sort
  end

  def number_of_students_by_age(age)
    show_students.map(&:age).count(age)
  end

  def participant_departments
    students.map(&:department).uniq.sort
  end

  def number_of_students_by_department(department)
    show_students.map(&:department).count(department.to_s)
  end

  def starts_at
    camps.any? ? camps.minimum(:starts_at) : Date.current + 1.day
  end

  def ends_at
    camps.any? ? camps.maximum(:ends_at) : Date.current + 10.days
  end

  def ended?
    ends_at <= Date.current if ends_at
  end

  def current?
    ends_at >= Date.current - 7.days if ends_at
  end

  def absenteeism_rate
    total_enrollments = camps.sum(&:total_enrollments_count)
    absent_enrollments = camps.sum(&:absent_enrollments_count)

    if total_enrollments.positive?
      ((absent_enrollments.to_f / total_enrollments) * 100).round(0)
    else
      0
    end
  end

  def absenteeism_rate_by_category(category)
    activities = Activity.where(camp: camps, category: category)
    total_enrollments_count = activities.sum { |activity| activity.enrollments_without_no_show.count }
    absent_enrollments_count = activities.sum { |activity| activity.absent_enrollments_count }
    if total_enrollments_count.positive?
      ((absent_enrollments_count.to_f / total_enrollments_count) * 100).round(0)
    else
      0
    end
  end

  def number_of_students_by_category(category)
    activity_enrollments.joins(:activity)
                        .where(activities: { category: category })
                        .count
  end

  def number_of_present_students_by_category(category)
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
    if number_of_present_students_by_category(category).positive?
      ((number_of_students_by_category_and_gender(category, gender).to_f / number_of_present_students_by_category(category)) * 100).round(0)
    else
      0
    end
  end

  def number_of_coaches_by_category(category)
    coaches.joins(activities: :camp)
           .where('activities.category_id = ? AND activities.camp_id IN (?)', category.id, camps.pluck(:id))
           .distinct
           .count
  end

  def can_import?
    if starts_at
      starts_at > Date.current
    else
      true
    end
  end

  def coaches_by_genre(genre)
    coaches.select { |coach| coach.gender == genre }
  end

  def new_students_count
    camps.sum(&:new_students_count)
  end

  # def expected_revenue
  #   camps.sum(&:expected_revenue)
  # end
  #
  def present_students_with_free_judo_ids
    camps.map(&:present_students_with_free_judo_ids).flatten
  end

  def expected_revenue
    camps.sum(&:expected_revenue)
  end

  def unexpected_revenue
    camp_enrollments.unattended.paid.count * price
  end

  def received_revenue
    camp_enrollments.paid
                    .where("payment_method IS NULL OR payment_method != ?", "offert")
                    .count * price
  end

  # def total_received_revenue
  #   camp_enrollments.paid
  #                   .where("payment_method IS NULL OR payment_method != ?", "offert")
  #                   .count * price
  # end

  def missing_revenue
    expected_revenue - received_revenue
  end

  def absent_paid_students_count
    camp_enrollments.unattended.paid.count
  end

  def total_old_camp_deposits
    camps.joins(:old_camp_deposits).sum('old_camp_deposits.amount')
  end

  def total_deposit
    camp_deposits.sum(:cash_amount) + 
    camp_deposits.sum(:cheque_amount) + 
    camp_enrollments.paid.where.not(payment_method: ["cash", "cheque", "offert"]).count * price 
  end

  def paid_students_count
    camp_enrollments.attended.paid.count
  end

  def unpaid_students_count
    camp_enrollments.attended.unpaid.count
  end

  # def missing_clarisse_revenue
  #   camps.sum(&:missing_clarisse_revenue)
  # end

  def present_students_with_free_judo_count
    camps.sum(&:present_students_with_free_judo_count)
  end

  private

  def normalize_name
    self.name = name.split.map(&:capitalize).join(' ')
  end

  def set_default_price
    self.price = 0 if paid == false
  end
end
