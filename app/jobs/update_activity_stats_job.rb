class UpdateActivityStatsJob < ApplicationJob
  queue_as :default

  def perform
    ActiveRecord::Base.transaction do
      Activity.find_each do |activity|
        next unless activity.current?
        if activity.activity_stat.nil?
          activity_stat = ActivityStat.new(activity: activity)
        else
          activity_stat = activity.activity_stat
        end
        activity_stat.students_count = activity.students_count
        activity_stat.coaches_count = activity.coaches.count
        activity_stat.number_of_boy = activity.number_of_students_by_genre("Garçon")
        activity_stat.number_of_girl = activity.number_of_students_by_genre("Fille")
        activity_stat.age_of_students = activity.age_of_students
        activity_stat.absenteeism_rate = activity.absenteeism_rate
        activity_stat.save!
      end
    end
  end

end
