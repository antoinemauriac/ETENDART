class AnnualProgram < ApplicationRecord
  belongs_to :academy

  has_many :annual_program_enrollments, dependent: :destroy
  has_many :students, through: :annual_program_enrollments

  has_many :program_periods, dependent: :destroy
  has_many :activities, dependent: :destroy
  has_many :courses, through: :activities

  accepts_nested_attributes_for :program_periods, reject_if: :all_blank, allow_destroy: true

  DAY_TO_WDAY = {
    "Dimanche" => 0,
    "Lundi" => 1,
    "Mardi" => 2,
    "Mercredi" => 3,
    "Jeudi" => 4,
    "Vendredi" => 5,
    "Samedi" => 6,
  }

  DAY_NAME_TO_NUMBER = {
    "Sunday" => 0,
    "Monday" => 1,
    "Tuesday" => 2,
    "Wednesday" => 3,
    "Thursday" => 4,
    "Friday" => 5,
    "Saturday" => 6,
    "No day assigned" => 7
  }

  def has_started?
    false
  end

  def find_all_specific_days(day_name)
    specific_days = []
    wday = DAY_TO_WDAY[day_name]

    program_periods.each do |period|
      start_date = period.start_date
      end_date = period.end_date

      (start_date..end_date).each do |date|
        specific_days << date if date.wday == wday
      end
    end

    specific_days.sort! { |a, b| a <=> b }
    specific_days
  end

  def sorted_activities
    activities.sort_by do |activity|
      DAY_NAME_TO_NUMBER[activity.day_of_activity]
    end
  end
end
