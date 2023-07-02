class SchoolPeriod < ApplicationRecord

  MESSAGE = "Avant de valider, avez vous-vérifier que les dates des camps sont correctes ?"

  belongs_to :academy
  has_many :camps, dependent: :destroy
  has_many :camp_enrollments, through: :camps
  has_many :students, through: :camp_enrollments

  has_many :activities, through: :camps
  has_many :activity_enrollments, through: :activities
  has_many :categories, through: :activities
  has_many :courses, through: :activities
  has_many :course_enrollments, through: :courses

  has_many :school_period_enrollments, dependent: :destroy
  # has_many :students, through: :school_period_enrollments

  # def students
  #   school_period_enrollments.map(&:student)
  # end

  def full_name
    "#{name} - #{year}"
  end

  def students_count
    students.count
  end

  def total_number_of_students(genre)
    camp_enrollments.joins(:student).where(students: { gender: genre }).count
  end

  def percentage_of_students(genre)
    if students_count.positive?
      ((total_number_of_students(genre).to_f / students_count) * 100).round(0)
    else
      0
    end
  end

  def age_of_students
    (students.map(&:age).sum.to_f / students.count).round(1)
  end

  def participant_ages
    students.map(&:age).uniq.sort
  end

  def number_of_students_by_age(age)
    students.map(&:age).count(age)
  end

  def participant_departments
    students.map(&:department).uniq.sort
  end

  def number_of_students_by_department(department)
    students.map(&:department).count(department)
  end

  def starts_at
    camps.minimum(:starts_at) if camps.any?
  end

  # def absenteeism_rate
  #   total_enrollments = course_enrollments.count
  #   absent_enrollments = course_enrollments.where(present: false).count
  #   if total_enrollments.positive?
  #     ((absent_enrollments.to_f / total_enrollments) * 100).round(0)
  #   else
  #     0
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

  def absenteeism_rate_by_category(category)
    enrollments = course_enrollments.joins({course: :activity}).where("courses.ends_at < ?", Time.current).where("activities.category_id = ?", category.id)
    total_enrollments = enrollments.count
    absent_enrollments = enrollments.unattended.count

    if total_enrollments.positive?
      ((absent_enrollments.to_f / total_enrollments) * 100).round(0)
    else
      0
    end
  end


  def number_of_students_by_category(category)
    activity_enrollments.joins(:activity).where(activities: { category: category }).count
  end

  def number_of_students_by_category_and_gender(category, gender)
    activity_enrollments.joins(:student, activity: :category).where(activities: { category: category }, students: { gender: gender }).count
  end


  def percentage_of_students_by_category_and_gender(category, gender)
    if number_of_students_by_category(category).positive?
      ((number_of_students_by_category_and_gender(category, gender).to_f / number_of_students_by_category(category)) * 100).round(0)
    else
      0
    end
  end


  # def absenteeism_rate_by_super_category(super_category)
  #   total_enrollments = course_enrollments.joins(:course).where("courses.ends_at < ?", Time.current).where("courses.category_id IN (?)", super_category.categories.ids).count

  def can_import?
    if starts_at
      starts_at > Date.today
    else
      true
    end
  end
end
