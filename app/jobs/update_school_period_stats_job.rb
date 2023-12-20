class UpdateSchoolPeriodStatsJob < ApplicationJob
  queue_as :default

  def perform
    ActiveRecord::Base.transaction do
      SchoolPeriod.find_each do |school_period|
        next unless school_period.current?
        if school_period.school_period_stat.nil?
          school_period_stat = SchoolPeriodStat.new(school_period: school_period)
        else
          school_period_stat = school_period.school_period_stat
        end
        school_period_stat.students_count = school_period.students_count
        school_period_stat.coaches_count = school_period.coaches.uniq.count
        school_period_stat.show_count = school_period.show_count
        school_period_stat.no_show_count = school_period.no_show_count
        school_period_stat.show_rate = school_period.show_rate
        school_period_stat.no_show_rate = school_period.no_show_rate
        school_period_stat.absenteeism_rate = school_period.absenteeism_rate

        school_period_stat.percentage_of_boy = school_period.percentage_of_students("Garçon")
        school_period_stat.percentage_of_girl = school_period.percentage_of_students("Fille")


        school_period_stat.age_of_students = school_period.age_of_students

        school_period_stat.participant_ages = school_period.participant_ages

        school_period_stat.participant_ages.each do |age|
          school_period_stat.student_count_by_age[age] = school_period.number_of_students_by_age(age)
        end

        school_period_stat.participant_departments = school_period.participant_departments.sort_by do |department|
          -school_period.number_of_students_by_department(department)
        end

        school_period_stat.participant_departments.each do |department|
          school_period_stat.student_count_by_department[department] = school_period.number_of_students_by_department(department)
        end

        school_period_stat.category_ids = school_period.categories.includes(:activities).uniq.sort_by do |category|
          school_period.number_of_students_by_category(category)
        end.reverse.pluck(:id)

        school_period_stat.category_ids.each do |id|
          school_period_stat.students_count_by_category[id] = school_period.number_of_students_by_category(Category.find(id))
          school_period_stat.percentage_of_boy_by_category[id] = school_period.percentage_of_students_by_category_and_gender(Category.find(id), "Garçon")
          school_period_stat.percentage_of_girl_by_category[id] = school_period.percentage_of_students_by_category_and_gender(Category.find(id), "Fille")
          school_period_stat.absenteisme_rate_by_category[id] = school_period.absenteeism_rate_by_category(Category.find(id))
          school_period_stat.number_of_coaches_by_category[id] = school_period.number_of_coaches_by_category(Category.find(id))
        end

        school_period_stat.save
      end
    end
  end

end
