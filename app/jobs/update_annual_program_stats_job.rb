class UpdateAnnualProgramStatsJob < ApplicationJob
  queue_as :default

  def perform
    ActiveRecord::Base.transaction do
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
  end

end
