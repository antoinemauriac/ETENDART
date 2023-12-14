class UpdateStatisticsJob < ApplicationJob
  queue_as :default

  def perform
    ActiveRecord::Base.transaction do
      update_school_period_stats
      update_camp_stats
      update_annual_program_stats
      update_activity_stats
    end
  end

  private

  def update_school_period_stats
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

  def update_camp_stats
    Camp.find_each do |camp|
      next unless camp.current?
      if camp.camp_stat.nil?
        camp_stat = CampStat.new(camp: camp)
      else
        camp_stat = camp.camp_stat
      end
      camp_stat.students_count = camp.students_count
      camp_stat.coaches_count = camp.coaches.count
      camp_stat.show_count = camp.show_count
      camp_stat.no_show_count = camp.no_show_count
      camp_stat.show_rate = camp.show_rate
      camp_stat.no_show_rate = camp.no_show_rate
      camp_stat.absenteeism_rate = camp.absenteeism_rate

      camp_stat.percentage_of_boy = camp.percentage_of_students_by_genre("Garçon")
      camp_stat.percentage_of_girl = camp.percentage_of_students_by_genre("Fille")


      camp_stat.age_of_students = camp.age_of_students

      camp_stat.percentage_of_boy
      camp_stat.participant_ages = camp.participant_ages

      camp_stat.participant_ages.each do |age|
        camp_stat.student_count_by_age[age] = camp.number_of_students_by_age(age)
      end

      camp_stat.participant_departments = camp.participant_departments

      camp_stat.participant_departments.each do |department|
        camp_stat.student_count_by_department[department] = camp.number_of_students_by_dpt(department)
      end

      camp_stat.save
    end
  end

  def update_annual_program_stats
    AnnualProgram.find_each do |annual_program|
      next unless annual_program.current?
      if annual_program.annual_program_stat.nil?
        annual_program_stat = AnnualProgramStat.new(annual_program: annual_program)
      else
        annual_program_stat = annual_program.annual_program_stat
      end
      annual_program_stat.students_count = annual_program.students_count
      annual_program_stat.coaches_count = annual_program.coaches.uniq.count
      annual_program_stat.show_count = annual_program.show_count
      annual_program_stat.no_show_count = annual_program.no_show_count
      annual_program_stat.show_rate = annual_program.show_rate
      annual_program_stat.no_show_rate = annual_program.no_show_rate
      annual_program_stat.absenteeism_rate = annual_program.absenteeism_rate

      annual_program_stat.percentage_of_boy = annual_program.percentage_of_students("Garçon")
      annual_program_stat.percentage_of_girl = annual_program.percentage_of_students("Fille")


      annual_program_stat.age_of_students = annual_program.age_of_students

      annual_program_stat.participant_ages = annual_program.participant_ages

      annual_program_stat.participant_ages.each do |age|
        annual_program_stat.student_count_by_age[age] = annual_program.number_of_students_by_age(age)
      end

      annual_program_stat.participant_departments = annual_program.participant_departments.sort_by do |department|
        -annual_program.number_of_students_by_dpt(department)
      end

      annual_program_stat.participant_departments.each do |department|
        annual_program_stat.student_count_by_department[department] = annual_program.number_of_students_by_dpt(department)
      end

      annual_program_stat.category_ids = annual_program.categories.includes(:activities).uniq.sort_by do |category|
        annual_program.number_of_students_by_category(category)
      end.reverse.pluck(:id)

      annual_program_stat.category_ids.each do |id|
        annual_program_stat.students_count_by_category[id] = annual_program.number_of_students_by_category(Category.find(id))
        annual_program_stat.percentage_of_boy_by_category[id] = annual_program.percentage_of_students_by_category_and_gender(Category.find(id), "Garçon")
        annual_program_stat.percentage_of_girl_by_category[id] = annual_program.percentage_of_students_by_category_and_gender(Category.find(id), "Fille")
        annual_program_stat.absenteisme_rate_by_category[id] = annual_program.absenteeism_rate_by_category(Category.find(id))
        annual_program_stat.number_of_coaches_by_category[id] = annual_program.number_of_coaches_by_category(Category.find(id))
      end

      annual_program_stat.save
    end
  end


  def update_activity_stats
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
