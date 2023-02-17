# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
CourseEnrollment.destroy_all
Course.destroy_all
ActivityEnrollment.destroy_all
Activity.destroy_all
Category.destroy_all
CoachCamp.destroy_all
CampEnrollment.destroy_all
Camp.destroy_all
SchoolPeriod.destroy_all
CoachAcademy.destroy_all
Location.destroy_all
AcademyEnrollment.destroy_all
Academy.destroy_all
Feedback.destroy_all
User.destroy_all
Student.destroy_all

tennis = Category.create!(name: 'Tennis')
basket = Category.create!(name: 'Basket')
manga = Category.create!(name: 'Manga')
theatre = Category.create!(name: 'Théâtre')
anglais = Category.create!(name: 'Anglais')
categories = [tennis, basket, manga, theatre, anglais]


manager1 = User.create!(email: 'manager1@gmail.com', password: 123456)
manager2 = User.create!(email: 'manager2@gmail.com', password: 123456)

coach1 = User.create!(email: 'coach1@gmail.com', password: 123456)
coach2 = User.create!(email: 'coach2@gmail.com', password: 123456)
coach3 = User.create!(email: 'coach3@gmail.com', password: 123456)
coachs = [coach1, coach2, coach3]

student1 = Student.create!(first_name: 'student', last_name: '1')
student2 = Student.create!(first_name: 'student', last_name: '2')
student3 = Student.create!(first_name: 'student', last_name: '3')

students = [student1, student2, student3]

djoko = Academy.create!(name: 'Djoko Academy', manager: manager1)
rudy = Academy.create!(name: 'Rudy Gobert Academy', manager: manager1)
angers = Academy.create!(name: 'Angers', manager: manager2)

location1 = Location.create!(address: '1 rue de la paix Clichy', academy: djoko)
location2 = Location.create!(address: '2 rue de la paix Clichy', academy: djoko)
location3 = Location.create!(address: '3 rue de la paix Levallois', academy: rudy)
location4 = Location.create!(address: '4 rue de la paix Levallois', academy: rudy)


djoko_avril_23 = SchoolPeriod.create!(name: 'djoko_avril_23', year: 2023, academy: djoko)
djoko_ete_23 = SchoolPeriod.create!(name: 'djoko_ete_23', year: 2023, academy: djoko)
rudy_avril_23 = SchoolPeriod.create!(name: 'rudy_avril_23', year: 2023, academy: rudy)
rudy_ete_23 = SchoolPeriod.create!(name: 'rudy_ete_23', year: 2023, academy: rudy)
angers_avril_23 = SchoolPeriod.create!(name: 'angers_avril_23', year: 2023, academy: angers)

week1_d = Camp.create!(name: 'semaine1', school_period: djoko_avril_23, starts_at: Date.new(2023, 4, 17), ends_at: Date.new(2021, 4, 21))
week2_d = Camp.create!(name: 'semaine2', school_period: djoko_avril_23, starts_at: Date.new(2023, 4, 24), ends_at: Date.new(2023, 4, 28))
week1_r = Camp.create!(name: 'semaine1', school_period: rudy_avril_23, starts_at: Date.new(2023, 4, 17), ends_at: Date.new(2023, 4, 21))
week2_r = Camp.create!(name: 'semaine2', school_period: rudy_avril_23, starts_at: Date.new(2023, 4, 24), ends_at: Date.new(2023, 4, 28))
week1_a = Camp.create!(name: 'semaine1', school_period: angers_avril_23, starts_at: Date.new(2023, 4, 17), ends_at: Date.new(2023, 4, 21))
weeks = [week1_d, week2_d, week1_r, week2_r, week1_a]

days1 = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']
days2 = ['Monday', 'Tuesday', 'Wednesday', 'Thursday']
days3 = ['Monday', 'Tuesday', 'Thursday']
days = [days1, days2, days3]

weeks.each do |week|
  3.times do |i|
    jours = days.sample
    Activity.create!(name: "activité #{i}",
                     days: jours,
                     coach: coachs.sample,
                     camp: week,
                     category: categories.sample)

    starts_at = week.starts_at

    date_array = jours.map do |day|
      date = starts_at
      while date.strftime("%A") != day
        date += 1
      end
      day = date
    end

    date_array.each do |date|
      starting_at = Time.new(date.year, date.month, date.day, rand(1..10), 0, 0)
      ending_at = starting_at + rand(1..3).hours
      Course.create!(starts_at: starting_at, ends_at: ending_at, activity: Activity.last, manager: manager1)
    end
  end

end

students.each do |student|
  AcademyEnrollment.create!(student: student, academy: djoko)
  CampEnrollment.create!(student: student, camp: week1_d)
  CampEnrollment.create!(student: student, camp: week2_d)
  ActivityEnrollment.create!(student: student, activity: week1_d.activities.first)
  ActivityEnrollment.create!(student: student, activity: week1_d.activities.second)
  ActivityEnrollment.create!(student: student, activity: week2_d.activities.first)
  ActivityEnrollment.create!(student: student, activity: week2_d.activities.second)

  week1_d.activities.first.courses.each do |course|
    CourseEnrollment.create!(student: student, course: course)
  end
  week1_d.activities.second.courses.each do |course|
    CourseEnrollment.create!(student: student, course: course)
  end
  week2_d.activities.first.courses.each do |course|
    CourseEnrollment.create!(student: student, course: course)
  end
  week2_d.activities.second.courses.each do |course|
    CourseEnrollment.create!(student: student, course: course)
  end
end
