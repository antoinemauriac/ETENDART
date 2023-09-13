class Student < ApplicationRecord

  validates :username, presence: true

  DEFAULT_AVATAR = "xkhgd88iqzlk5ctay2hu.png"

  scope :today_birthday, -> { where('EXTRACT(month FROM date_of_birth) = ? AND EXTRACT(day FROM date_of_birth) = ?', Date.today.month, Date.today.day).order("created_at DESC") }

  attr_accessor :academy1_id, :academy2_id

  has_one_attached :photo

  has_many :academy_enrollments, dependent: :destroy
  has_many :academies, through: :academy_enrollments

  has_many :school_period_enrollments, dependent: :destroy
  has_many :school_periods, through: :school_period_enrollments

  has_many :camp_enrollments, dependent: :destroy
  has_many :camps, through: :camp_enrollments

  has_many :activity_enrollments, dependent: :destroy
  has_many :activities, through: :activity_enrollments

  has_many :course_enrollments, dependent: :destroy
  has_many :courses, through: :course_enrollments

  has_many :feedbacks, dependent: :destroy

  def full_name
    if first_name && last_name
      "#{first_name} #{last_name}"
    elsif first_name && !last_name
      first_name
    elsif !first_name && last_name
      last_name
    else
      "No name"
    end
  end

  def full_name_separator
    if first_name && last_name
      "#{last_name.upcase} - #{first_name}"
    elsif first_name && !last_name
      first_name
    elsif !first_name && last_name
      last_name.upcase
    else
      "No name"
    end
  end


  def courses_sorted
    courses.order(starts_at: :asc)
  end

  def past_courses
    courses.where('starts_at < ?', Time.current)
           .order(starts_at: :desc)
  end

  def unattended_courses
    course_enrollments.unattended
                      .joins(:course)
                      .where('courses.ends_at < ?', Time.current)
  end

  def unattended_today_courses
    course_enrollments.unattended
                      .joins(:course)
                      .where(courses: { ends_at: Date.current.all_day })
  end

  def next_courses
    courses.where('starts_at > ?', Time.current)
           .order(starts_at: :asc)
  end

  def courses_count
    courses.count
  end

  def past_courses_count(activity=nil)
    if activity
      courses.where('ends_at < ? AND activity_id = ?', Time.current, activity.id).count
    else
      courses.where('ends_at < ?', Time.current).count
    end
  end

  def unattended_courses_count(options = { camp: nil, activity: nil })
    activity = options[:activity] if options.present?
    camp = options[:camp] if options.present?

    if activity
      course_enrollments.unattended.joins(:course)
                        .where('courses.ends_at < ?', Time.current)
                        .where('courses.activity_id = ?', activity.id)
                        .count
    elsif camp
      course_enrollments.unattended.joins(course: :camp)
                        .where('courses.ends_at < ?', Time.current)
                        .where('camps.id = ?', camp.id)
                        .count
    else
      course_enrollments.unattended.joins(:course)
                        .where('courses.ends_at < ?', Time.current)
                        .count
    end
  end

  def unattended_rate(activity = nil)
    past_count = past_courses_count(activity)
    unattended_count = unattended_courses_count(activity: activity)

    if past_count.positive?
      (unattended_count.to_f / past_count * 100).round
    else
      0
    end
  end

  def activities_count
    activities.count
  end

  def camps_count
    camps.count
  end

  def student_activities(camp)
    activities.where(camp: camp)
  end

  def age
    if date_of_birth
      now = Time.current
      birthdate = date_of_birth.to_date
      age = now.year - birthdate.year
      age -= 1 if birthdate.strftime("%m%d").to_i > now.strftime("%m%d").to_i
      age
    end
  end

  def department
    if zipcode
      zipcode.to_s.first(2)
    else
      "No zipcode"
    end
  end

  def active_camps
    Camp.joins(:camp_enrollments)
        .where(camp_enrollments: { banished: false, student_id: id })
  end

  def activities_with_next_courses
    activities.joins(:camp).merge(active_camps)
              .where('camps.ends_at > ?', Time.current)
              .where(id: Activity.joins(camp: :courses)
                                .merge(next_courses)
                                .select(:id))
              .order('camps.starts_at ASC')
  end

  def next_courses_by_activity(activity)
    courses.where('starts_at > ?', Time.current)
            .where(activity_id: activity.id)
            .order(starts_at: :asc)
  end

  def next_activities
    activities.joins(:camp).merge(active_camps)
              .where('camps.ends_at > ?', Time.current)
              .order('camps.starts_at ASC')
  end

  def self.today_absent_students(manager)
    joins(course_enrollments: { course: :academy })
      .where(course_enrollments: { present: false })
      .where(courses: { starts_at: Time.current.all_day, manager_id: manager.id })
      .where(academies: { id: manager.academies_as_manager.pluck(:id) })
      .distinct
  end

  def first_academy
    academies.first
  end

  def photo_or_default
    if photo.attached?
      photo.key
    else
      DEFAULT_AVATAR
    end
  end

  def phone_modified
    if phone_number
      if phone_number.length == 9
        "0#{phone_number}"
      else
        phone_number
      end
    else
      "No phone number"
    end
  end

  def self.find_duplicates(threshold = 2)
    all_students = all.to_a

    duplicates = []

    until all_students.empty?
      student = all_students.pop
      similar_students = [student]

      all_students.each do |other_student|
        # Calculate the Levenshtein distance for first_name and last_name
        first_name_distance = Text::Levenshtein.distance(student.first_name, other_student.first_name)
        last_name_distance = Text::Levenshtein.distance(student.last_name, other_student.last_name)

        # If both first_name and last_name are similar enough, consider them duplicates
        if first_name_distance <= threshold && last_name_distance <= threshold
          similar_students << other_student
        end
      end

      # Remove the duplicates from the main list to avoid checking them again
      all_students -= similar_students

      # Add the group of duplicates to the results
      duplicates << similar_students if similar_students.size > 1
    end

    duplicates
  end

  def self.find_duplicates_separate(threshold_first_name = 2, threshold_last_name = 2)
    all_students = all.to_a

    duplicates = []

    until all_students.empty?
      student = all_students.pop
      similar_students = [student]

      all_students.each do |other_student|
        # Calculate the Levenshtein distance for first_name and last_name separately
        first_name_distance = Text::Levenshtein.distance(student.first_name, other_student.first_name)
        last_name_distance = Text::Levenshtein.distance(student.last_name, other_student.last_name)

        # If both first_name and last_name are similar enough, consider them duplicates
        if first_name_distance <= threshold_first_name && last_name_distance <= threshold_last_name
          similar_students << other_student
        end
      end

      # Remove the duplicates from the main list to avoid checking them again
      all_students -= similar_students

      # Add the group of duplicates to the results
      duplicates << similar_students if similar_students.size > 1
    end

    duplicates
  end
end
