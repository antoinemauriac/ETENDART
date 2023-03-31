# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: "Star Wars" }, { name: "Lord of the Rings" }])
#   Character.create(name: "Luke", movie: movies.first)
UserRole.destroy_all
Role.destroy_all
CourseEnrollment.destroy_all
Course.destroy_all
ActivityEnrollment.destroy_all
Activity.destroy_all
CoachCategory.destroy_all
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
# manga = Category.create!(name: 'Manga')
theatre = Category.create!(name: 'Théâtre')
anglais = Category.create!(name: 'Anglais')
danse = Category.create!(name: 'Danse')
categories = [tennis, basket, theatre, anglais, danse]

Role.create!(name: 'manager')
Role.create!(name: 'coach')

manager1 = User.create!(email: 'manager1@gmail.com', password: 123456)
manager1.roles << Role.find_by(name: 'manager')
manager2 = User.create!(email: 'manager2@gmail.com', password: 123456)
manager2.roles << Role.find_by(name: 'manager')

coach1 = User.create!(email: 'coach1@gmail.com', password: 123456, first_name: "Remi", last_name: "Martin")
coach1.roles << Role.find_by(name: 'coach')
coach2 = User.create!(email: 'coach2@gmail.com', password: 123456, first_name: "Lucie", last_name: "Durand")
coach2.roles << Role.find_by(name: 'coach')
coach3 = User.create!(email: 'coach3@gmail.com', password: 123456, first_name: "Thierry", last_name: "Leroy")
coach3.roles << Role.find_by(name: 'coach')
coach4 = User.create!(email: 'coach4@gmail.com', password: 123456, first_name: "Myriam", last_name: "Diallo")
coach4.roles << Role.find_by(name: 'coach')

coaches = [coach1, coach2, coach3]

# student1 = Student.create!(first_name: 'Leo', last_name: 'Minot')
# student2 = Student.create!(first_name: 'Lea', last_name: 'Lala')
# student3 = Student.create!(first_name: 'Toto', last_name: 'Zizou')

# students = [student1, student2, student3]

djoko = Academy.create!(name: 'Djoko', manager: manager1)
djoko_image = URI.open('https://res.cloudinary.com/dushuxqmj/image/upload/v1680268116/etendart/dz0etqpbqcgkxps78kgm.jpg')
djoko.image.attach(io: djoko_image, filename: 'djoko-court.jpg', content_type: 'image/jpg')
djoko.save
rudy = Academy.create!(name: 'Rudy Gobert', manager: manager1)
rudy_image = URI.open('https://res.cloudinary.com/dushuxqmj/image/upload/v1680268116/etendart/lkvegtvhzgdhrve2wo6g.jpg')
rudy.image.attach(io: rudy_image, filename: 'rudy-court.jpg', content_type: 'image/jpg')
rudy.save
angers = Academy.create!(name: 'Angers', manager: manager2)
angers_image = URI.open('https://res.cloudinary.com/dushuxqmj/image/upload/v1680268116/etendart/tchrkajvhzrs8ucm8fv6.jpg')
angers.image.attach(io: angers_image, filename: 'angers-court.jpg', content_type: 'image/jpg')
angers.save


coach1.academies_as_coach << djoko
coach1.categories << tennis
coach1.categories << danse
coach2.academies_as_coach << djoko
coach2.categories << danse
coach3.academies_as_coach << djoko
coach3.categories << tennis


location1 = Location.create!(address: '1 rue de la paix Clichy', academy: djoko, name: 'Clichy1')
location2 = Location.create!(address: '2 rue de la paix Clichy', academy: djoko, name: 'Clichy2')
location3 = Location.create!(address: '3 rue de la paix Levallois', academy: rudy, name: 'Levallois1')
location4 = Location.create!(address: '4 rue de la paix Levallois', academy: rudy, name: 'Levallois2')
locations = [location1, location2, location3, location4]


# djoko_fevrier_23 = SchoolPeriod.create!(name: 'février', year: 2023, academy: djoko)
# djoko_avril_23 = SchoolPeriod.create!(name: 'avril', year: 2023, academy: djoko)
# djoko_ete_23 = SchoolPeriod.create!(name: 'été', year: 2023, academy: djoko)
# rudy_avril_23 = SchoolPeriod.create!(name: 'avril', year: 2023, academy: rudy)
# rudy_ete_23 = SchoolPeriod.create!(name: 'été', year: 2023, academy: rudy)
# angers_avril_23 = SchoolPeriod.create!(name: 'avril', year: 2023, academy: angers)

# week0_d = Camp.create!(name: 'semaine1', school_period: djoko_fevrier_23, starts_at: Date.new(2023, 2, 2), ends_at: Date.new(2023, 2, 18))
# week1_d = Camp.create!(name: 'semaine1', school_period: djoko_avril_23, starts_at: Date.new(2023, 4, 17), ends_at: Date.new(2023, 4, 21))
# week2_d = Camp.create!(name: 'semaine2', school_period: djoko_avril_23, starts_at: Date.new(2023, 4, 24), ends_at: Date.new(2023, 4, 28))
# week1_r = Camp.create!(name: 'semaine1', school_period: rudy_avril_23, starts_at: Date.new(2023, 4, 17), ends_at: Date.new(2023, 4, 21))
# week2_r = Camp.create!(name: 'semaine2', school_period: rudy_avril_23, starts_at: Date.new(2023, 4, 24), ends_at: Date.new(2023, 4, 28))
# week1_a = Camp.create!(name: 'semaine1', school_period: angers_avril_23, starts_at: Date.new(2023, 4, 17), ends_at: Date.new(2023, 4, 21))
# weeks = [week1_d, week2_d, week1_r, week2_r, week1_a]

# days1 = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday']
# days2 = ['Monday', 'Tuesday', 'Wednesday', 'Thursday']
# days3 = ['Monday', 'Tuesday', 'Thursday']
# days = [days1, days2, days3]
# activities = ['Tennis(8-12ans)', 'Tennis(12-16ans)', 'Web Design (entre 2008 et 2005)', 'Danse (entre 2008 et 2005)']

# weeks.each do |week|
#   activities.length.times do |i|
#     jours = days.sample
#     coach = coaches.sample
#     Activity.create!(name: activities[i],
#                      days: jours,
#                      coach: coach,
#                      camp: week,
#                      category: categories.sample,
#                      location: locations.sample)

#     coach.camps << week unless coach.camps.include?(week)
#     starts_at = week.starts_at

#     date_array = jours.map do |day|
#       date = starts_at
#       while date.strftime("%A") != day
#         date += 1
#       end
#       day = date
#     end

#     date_array.each do |date|
#       starting_at = Time.new(date.year, date.month, date.day, rand(1..10), 0, 0)
#       ending_at = starting_at + rand(1..3).hours
#       Course.create!(starts_at: starting_at, ends_at: ending_at, activity: Activity.last, manager: manager1, coach: coach)
#     end
#   end
# end

# students.each do |student|
#   AcademyEnrollment.create!(student: student, academy: djoko)
#   CampEnrollment.create!(student: student, camp: week1_d)
#   CampEnrollment.create!(student: student, camp: week2_d)
#   ActivityEnrollment.create!(student: student, activity: week1_d.activities.first)
#   ActivityEnrollment.create!(student: student, activity: week1_d.activities.second)
#   ActivityEnrollment.create!(student: student, activity: week2_d.activities.first)
#   ActivityEnrollment.create!(student: student, activity: week2_d.activities.second)

#   week1_d.activities.first.courses.each do |course|
#     CourseEnrollment.create!(student: student, course: course)
#   end
#   week1_d.activities.second.courses.each do |course|
#     CourseEnrollment.create!(student: student, course: course)
#   end
#   week2_d.activities.first.courses.each do |course|
#     CourseEnrollment.create!(student: student, course: course)
#   end
#   week2_d.activities.second.courses.each do |course|
#     CourseEnrollment.create!(student: student, course: course)
#   end
# end
