# Category.create!(name: 'Tennis', super_category: 'Sport')
# Category.create!(name: 'Manga', super_category: 'Eveil')

# Role.create!(name: 'manager')
# Role.create!(name: 'coach')

# antoine = User.create(email: "mauriac.antoine@gmail.com", password: 123456, admin: true)
# antoine.roles << Role.find_by(name: 'manager')
# ornella = User.create!(email: 'ornella@etendart.org', password: 123456)
# ornella.roles << Role.find_by(name: 'manager')

# troyes = Academy.create!(name: 'Troyes', manager: raf)
# troyes_image = URI.open('https://res.cloudinary.com/dushuxqmj/image/upload/v1719924175/etendart/dc9cj1djqigxocxtad33.jpg')
# troyes.image.attach(io: troyes_image, filename: 'troyes-court.jpg', content_type: 'image/jpg')

# grasse = Academy.create!(name: 'Grasse', manager: raf)
# grass_image = URI.open('https://res.cloudinary.com/dushuxqmj/image/upload/v1719924175/etendart/a7mpkq8zxmsmk9fcmnwc.jpg')
# grasse.image.attach(io: grass_image, filename: 'grasse-court.jpg', content_type: 'image/jpg')


# marseille = Academy.create!(name: 'Marseille', manager: raf)
# marseille_image = URI.open('https://res.cloudinary.com/dushuxqmj/image/upload/v1730987600/etendart/lci2fsktm8yaygm45ja1.png')
# marseille.image.attach(io: marseille_image, filename: 'marseille-court.jpg', content_type: 'image/jpg')

# angers = Academy.create!(name: 'Angers', manager: ornella)
# angers_image = URI.open('https://res.cloudinary.com/dushuxqmj/image/upload/v1685022761/etendart/szhjycwofx768fuvmurf.jpg')
# angers.image.attach(io: angers_image, filename: 'angers-court.jpg', content_type: 'image/jpg')
# angers.save
#
# paris = Academy.create!(name: 'Paris 9', manager: User.find(94))
# paris_image = URI.open('https://res.cloudinary.com/dushuxqmj/image/upload/v1728994736/etendart/pp5qu9nfz6nrwxeajj1k.jpg')
# paris.image.attach(io: paris_image, filename: 'paris-court.jpg', content_type: 'image/jpg')
# paris.save


# strasbourg = Academy.create!(name: 'Strasbourg', manager: ornella)
# strasbourg_image = URI.open('https://res.cloudinary.com/dushuxqmj/image/upload/v1685022664/etendart/jr1urgr52c8yls0icjdk.png')
# strasbourg.image.attach(io: strasbourg_image, filename: 'strasbourg-court.jpg', content_type: 'image/jpg')
# strasbourg.save

# saint_quentin = Academy.create!(name: 'Saint-Quentin', manager: ornella)
# saint_quentin_image = URI.open('https://res.cloudinary.com/dushuxqmj/image/upload/v1685022663/etendart/wn1pkzmautra2tlhvqqh.jpg')
# saint_quentin.image.attach(io: saint_quentin_image, filename: 'saint-quentin-court.jpg', content_type: 'image/jpg')
# saint_quentin.save


# eole = Academy.create!(name: 'Éole', manager: celine)
# eole_image = URI.open('https://res.cloudinary.com/dushuxqmj/image/upload/v1687172446/etendart/scsq3kipduarl3dobesk.jpg')
# eole.image.attach(io: eole_image, filename: 'eole-court.jpg', content_type: 'image/jpg')
# eole.save

# celine = User.find_by(email: 'celine@etendart.org')
# clichy_levallois = Academy.create!(name: 'Clichy-Levallois', manager: celine, annual: true)
# clichy_levallois_image = URI.open('https://res.cloudinary.com/dushuxqmj/image/upload/v1695041073/etendart/ii2atulzrgap7rwikcbw.png')
# clichy_levallois.image.attach(io: clichy_levallois_image, filename: 'clichy-levallois.png', content_type: 'image/png')
# clichy_levallois.save

# strasbourg_image = URI.open('https://res.cloudinary.com/dushuxqmj/image/upload/v1681745643/etendart/sr6nqll54ykkr03jqvgn.jpg')
# strasbourg.image.attach(io: strasbourg_image, filename: 'strasbourg-court.jpg', content_type: 'image/jpg')
# strasbourg.save

# Academy.create!(name: 'Djokovic', manager: antoine)
# djoko = Academy.find_by(name: 'Djokovic')
# djoko_image = URI.open('https://res.cloudinary.com/dushuxqmj/image/upload/v1681745643/etendart/sr6nqll54ykkr03jqvgn.jpg')
# djoko.image.attach(io: djoko_image, filename: 'djoko-court.jpg', content_type: 'image/jpg')
# djoko.save

# Academy.create!(name: 'Rudy Gobert', manager: antoine)
# rudy = Academy.find_by(name: 'Rudy Gobert')
# rudy_image = URI.open('https://res.cloudinary.com/dushuxqmj/image/upload/v1681745643/etendart/b5cmmg95x1kuvmtm9ysu.jpg')
# rudy.image.attach(io: rudy_image, filename: 'rudy-court.jpg', content_type: 'image/jpg')
# rudy.save

# manga = Category.create!(name: 'Manga')
# theatre = Category.create!(name: 'Théâtre')
# anglais = Category.create!(name: 'Anglais')
# danse = Category.create!(name: 'Danse')
# categories = [tennis, basket, theatre, anglais, danse, manga]
# manager2 = User.create!(email: 'manager2@gmail.com', password: 123456)
# manager2.roles << Role.find_by(name: 'manager')

# coach1 = User.create!(email: 'coach1@gmail.com', password: 123456, first_name: "Remi", last_name: "Martin")
# coach1.roles << Role.find_by(name: 'coach')
# coach2 = User.create!(email: 'coach2@gmail.com', password: 123456, first_name: "Lucie", last_name: "Durand")
# coach2.roles << Role.find_by(name: 'coach')
# coach3 = User.create!(email: 'coach3@gmail.com', password: 123456, first_name: "Thierry", last_name: "Leroy")
# coach3.roles << Role.find_by(name: 'coach')
# coach4 = User.create!(email: 'coach4@gmail.com', password: 123456, first_name: "Myriam", last_name: "Diallo")
# coach4.roles << Role.find_by(name: 'coach')
# coach5 = User.create!(email: 'coach5@gmail.com', password: 123456, first_name: "Imane", last_name: "Ali")
# coach5.roles << Role.find_by(name: 'coach')

# coach1.academies_as_coach << Academy.first
# coach2.academies_as_coach << Academy.first
# coach3.academies_as_coach << djoko
# coach4.academies_as_coach << djoko
# coach5.academies_as_coach << djoko


# coaches = [coach1, coach2, coach3]

# student1 = Student.create!(first_name: 'Leo', last_name: 'Minot')
# student2 = Student.create!(first_name: 'Lea', last_name: 'Lala')
# student3 = Student.create!(first_name: 'Toto', last_name: 'Zizou')

# students = [student1, student2, student3]

# angers = Academy.create!(name: 'Angers', manager: manager2)
# angers_image = URI.open('https://res.cloudinary.com/dushuxqmj/image/upload/v1680268116/etendart/tchrkajvhzrs8ucm8fv6.jpg')
# angers.image.attach(io: angers_image, filename: 'angers-court.jpg', content_type: 'image/jpg')
# angers.save


# coach1.academies_as_coach << djoko
# coach1.academies_as_coach << rudy
# coach1.categories << tennis
# coach1.categories << manga
# coach2.academies_as_coach << djoko
# coach2.academies_as_coach << rudy
# coach2.categories << tennis
# coach2.categories << theatre
# coach3.academies_as_coach << djoko
# coach3.academies_as_coach << rudy
# coach3.categories << manga
# coach3.categories << theatre
# coach4.academies_as_coach << djoko
# coach4.academies_as_coach << rudy
# coach4.categories << basket
# coach4.categories << manga
# coach5.academies_as_coach << djoko
# coach5.academies_as_coach << rudy
# coach5.categories << basket
# coach5.categories << theatre


# location1 = Location.create!(address: '1 rue de la paix Clichy', academy: djoko, name: 'Clichy1')
# location2 = Location.create!(address: '2 rue de la paix Clichy', academy: djoko, name: 'Clichy2')
# location3 = Location.create!(address: '3 rue de la paix Levallois', academy: rudy, name: 'Levallois1')
# location4 = Location.create!(address: '4 rue de la paix Levallois', academy: rudy, name: 'Levallois2')
# locations = [location1, location2, location3, location4]


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
#
# SchoolPeriod.destroy_all

# 80.times do
#   student = Student.create!(
#     first_name: Faker::Name.first_name,
#     last_name: Faker::Name.last_name,
#     date_of_birth: Faker::Date.birthday(min_age: 5, max_age: 18),
#     email: Faker::Internet.email,
#     phone_number: Faker::PhoneNumber.cell_phone,
#     gender: ['Garçon', 'Fille'].sample,
#     username: Faker::Internet.username,
#     )
#     student.academies << Academy.first
# end
