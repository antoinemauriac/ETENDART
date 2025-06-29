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

  has_many :old_camp_deposits, dependent: :destroy
  has_many :camp_deposits, dependent: :destroy

  validates :name, presence: true
  validates :starts_at, presence: true
  validates :ends_at, presence: true

  validate :starts_at_must_be_before_ends_at
  validates :name, uniqueness: { scope: [:school_period_id], message: "Une semaine avec le même nom existe déjà pour ce stage" }

  # Scopes pour les camps pleins/non pleins
  scope :full, -> { where("capacity <= (SELECT COUNT(*) FROM camp_enrollments WHERE camp_enrollments.camp_id = camps.id AND camp_enrollments.confirmed = true)") }
  scope :not_full, -> { where("capacity > (SELECT COUNT(*) FROM camp_enrollments WHERE camp_enrollments.camp_id = camps.id AND camp_enrollments.confirmed = true)") }


  def format_starts_at_ends_at
    if starts_at && ends_at
      "Du #{starts_at.strftime('%d/%m/%Y')} au #{ends_at.strftime('%d/%m/%Y')}"
    else
      "Dates non définies"
    end
  end

  def full?
    camp_enrollments.confirmed.count >= capacity
  end

  def full_name
    "#{academy.name}-#{school_period.full_name_short}-#{name}"
  end

  def full_name_separator
    "#{academy.name}-#{school_period.full_name_separator}-#{name}"
  end

  def format_price
    if school_period.paid
      if price == 0
        "Gratuit"
      else
        "#{price}€"
      end
    else
      "Gratuit"
    end
  end

  def short_name
    name.split("").first + name.split("").last
  end

  def current?
    ends_at >= Time.current - 14.days
  end

  def banished_students
    students.joins(:camp_enrollments).where(camp_enrollments: { banished: true }).uniq
  end

  def confirmed_students
    students.joins(:camp_enrollments).where(camp_enrollments: { confirmed: true })
  end

  def students_count
    camp_enrollments.confirmed.count
  end

  def show_students
    students.joins(:camp_enrollments).where(camp_enrollments: { present: true, confirmed: true, camp_id: id }).distinct
  end

  def show_count
    show_students.count
  end

  def no_show_students
    students.joins(:camp_enrollments).where(camp_enrollments: { confirmed: true }).distinct - show_students
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

  def has_paid_enrollments?
    camp_enrollments.where(paid: true).any?
  end

  def can_delete?
    !has_paid_enrollments?
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
    show_students.select { |student| student.confirmed_camps.where('starts_at < ?', starts_at).empty? }.count
  end

  def new_students_rate
    if show_count.positive?
      ((new_students_count.to_f / show_count) * 100).round(0)
    else
      0
    end
  end

  def expected_revenue
    unattend_paid_count = camp_enrollments.unattended.paid.count
    paid_enrollments = camp_enrollments.paid.where(payment_method: "offert").count
    if self.school_period.free_judo == true
      (camp_enrollments.attended.where.not(student_id: present_students_with_free_judo_ids).count +
        unattend_paid_count -
        paid_enrollments) *
        price
    else
      (camp_enrollments.attended.count +
        unattend_paid_count -
        paid_enrollments) *
        price
    end
  end

  def expected_count_revenue
    unattend_paid_count = camp_enrollments.unattended.paid.count
    paid_enrollments_count = camp_enrollments.paid.where(payment_method: "offert").count
    if self.school_period.free_judo == true
      camp_enrollments.attended.where.not(student_id: present_students_with_free_judo_ids).count +
        unattend_paid_count -
        paid_enrollments_count
    else
      camp_enrollments.attended.count +
        unattend_paid_count-
        paid_enrollments_count
    end
  end

  def present_received_revenue
    camp_enrollments.attended.paid.count * price
  end

  def absent_received_revenue
    camp_enrollments.unattended.paid.count * price
  end

  def total_received_revenue
    camp_enrollments.paid
                    .where("payment_method IS NULL OR payment_method != ?", "offert")
                    .count * price
  end

  def paid_students_count
    camp_enrollments.attended.paid.count
  end

  def unpaid_students_count
    camp_enrollments.attended.unpaid.count
  end

  def absent_paid_students_count
    camp_enrollments.unattended.paid.count
  end

  def present_students_with_free_judo
    if school_period.free_judo == true
      judo_activity_ids = self.activities.joins(:category).where(categories: { name: 'Judo' }).pluck(:id)
      show_students.joins(:courses).where(courses: { activity_id: judo_activity_ids }).distinct
      # show_students.select { |student| student.courses.where(activity_id: judo_activity_ids).exists? }
    else
      []
    end
  end

  def all_students_with_free_judo
    if school_period.free_judo == true
      judo_activity_ids = self.activities.joins(:category).where(categories: { name: 'Judo' }).pluck(:id)
      students.joins(:courses).where(courses: { activity_id: judo_activity_ids }).distinct
    else
      []
    end
  end

  def present_students_with_free_judo_ids
    present_students_with_free_judo.map(&:id)
  end

  def present_students_with_free_judo_count
    present_students_with_free_judo.count
  end

  private

  def starts_at_must_be_before_ends_at
    errors.add(:starts_at, :after) if starts_at >= ends_at
  end
end
