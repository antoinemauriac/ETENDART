class ActivityStat < ApplicationRecord
  belongs_to :activity
end

# ActivityStat.destroy_all

# school_period = SchoolPeriod.find(14)
# activities = school_period.activities

# activities.each do |activity|
#   activity_stat = ActivityStat.new(activity: activity)
#   activity_stat.students_count = activity.students_count
#   activity_stat.coaches_count = activity.coaches.count
#   activity_stat.number_of_boy = activity.number_of_students_by_genre("Garçon")
#   activity_stat.number_of_girl = activity.number_of_students_by_genre("Fille")
#   activity_stat.age_of_students = activity.age_of_students
#   activity_stat.absenteeism_rate = activity.absenteeism_rate
#   activity_stat.save!
# end
