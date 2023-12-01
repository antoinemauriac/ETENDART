class CampStat < ApplicationRecord
  belongs_to :camp
end


# CampStat.destroy_all
# school_period = SchoolPeriod.find(14)

# school_period.camps.each do |camp|
#   camp_stat = CampStat.new(camp:)
#   camp_stat.students_count = camp.students_count
#   camp_stat.coaches_count = camp.coaches.count
#   camp_stat.show_count = camp.show_count
#   camp_stat.no_show_count = camp.no_show_count
#   camp_stat.show_rate = camp.show_rate
#   camp_stat.no_show_rate = camp.no_show_rate
#   camp_stat.absenteeism_rate = camp.absenteeism_rate

#   camp_stat.percentage_of_boy = camp.percentage_of_students_by_genre("Garçon")
#   camp_stat.percentage_of_girl = camp.percentage_of_students_by_genre("Fille")


#   camp_stat.age_of_students = camp.age_of_students

#   camp_stat.percentage_of_boy
#   camp_stat.participant_ages = camp.participant_ages

#   camp_stat.participant_ages.each do |age|
#     camp_stat.student_count_by_age[age] = camp.number_of_students_by_age(age)
#   end

#   camp_stat.participant_departments = camp.participant_departments

#   camp_stat.participant_departments.each do |department|
#     camp_stat.student_count_by_department[department] = camp.number_of_students_by_dpt(department)
#   end

#   camp_stat.save
# end
