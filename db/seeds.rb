require 'faker'
# NB : POUR L'EXECUTION DES BACKGROUND JOB (ACTIVITY_STAT, CAMP_STAT...),
# PENSER À MODIFIER LES FICHIERS EN COMMENTANT 'NEXT UNLESS MODEL.CURRENT?'


# STOP EXECUTION IF THE ENVIRONMENT IS PRODUCTION
if Rails.env.production?
  raise "Seeds should not be run in production!"
end


# DESTROY ALL
Feedback.destroy_all
ActivityStat.destroy_all
CampStat.destroy_all
SchoolPeriodStat.destroy_all
AnnualProgramStat.destroy_all
CourseEnrollment.destroy_all
Course.destroy_all
ActivityEnrollment.destroy_all
Activity.destroy_all
CampEnrollment.destroy_all
Camp.destroy_all
SchoolPeriodEnrollment.destroy_all
SchoolPeriod.destroy_all
MembershipDeposit.destroy_all
Membership.destroy_all
CampDeposit.destroy_all
OldCampDeposit.destroy_all
Student.destroy_all
Location.destroy_all
AnnualProgram.destroy_all
CoachAcademy.destroy_all
Academy.destroy_all
UserRole.destroy_all
Role.destroy_all
User.destroy_all
Category.destroy_all

# CATEGORIES AND ACTIVITY NAME
categories = {
  "Sport" => ["Tennis", "Basket"],
  "Eveil" => ["Danse", "Théâtre", "Manga", "Anglais"],
  "Cuisine" => ["Cuisine"],
  "Accompagnement" => ["Accompagnement"]
}

categories.each do |super_category, sub_categories|
  sub_categories.each do |name|
    Category.create!(name: name, super_category: super_category)
  end
end

# CREATE ACTIVITY NAMES USING THINGS LIKE (8-12ANS), 14H-16H, OR JUSTE THE CATEGORY NAME
def generate_activity_name(category_name)
  first_age_range = " 8-12ans"
  time_range = " #{rand(14..16)}h-#{rand(17..19)}h"
  [category_name, "#{category_name}#{first_age_range}", "#{category_name}#{time_range}"].sample
end


# ROLES
roles = ["admin", "manager", "coordinator", "coach"]
roles.each do |role|
  Role.create!(name: role)
end


# CREATE 6 USERS, DONT 1 ADMIN, 1 MANAGER, 1 COORDINATOR AND 3 COACHES (ROLES)
manager = User.create!(email: 'manager@gmail.com', password: 123456, first_name: "Titi", last_name: "Dupont", phone_number: "06 12 34 56 78", status: "", gender: 'Garçon')
manager1 = User.create!(email: 'manager1@gmail.com', password: 123456, first_name: "Leon", last_name: "Marchand", phone_number: "06 12 34 56 78", status: "", gender: 'Garçon')
coordinator = User.create!(email: 'coordinator@gmail.com', password: 123456, first_name: "Toto", last_name: "Dupont", phone_number: "06 12 34 56 78", status: "", gender: 'Garçon')
admin = User.create!(email: 'admin@gmail.com', password: 123456, first_name: "Ibrahim", last_name: "Ba", phone_number: "06 12 34 56 78", status: "", gender: 'Garçon')
coach1 = User.create!(email: 'coach1@gmail.com', password: 123456, first_name: "Lea", last_name: "Martin", phone_number: "06 12 34 56 78", status: "", gender: 'Fille')
coach2 = User.create!(email: 'coach2@gmail.com', password: 123456, first_name: "Leila", last_name: "El Amrani", phone_number: "06 12 34 56 78", status: "", gender: 'Fille')
coach3 = User.create!(email: 'coach3@gmail.com', password: 123456, first_name: "John", last_name: "Doe", phone_number: "06 12 34 56 78", status: "", gender: 'Garçon')

# ASSIGN ROLES TO USERS
manager.roles << Role.find_by(name: 'manager')
manager1.roles << Role.find_by(name: 'manager')
coordinator.roles << Role.find_by(name: 'coordinator')
admin.roles << Role.find_by(name: 'admin')
coach1.roles << Role.find_by(name: 'coach')
coach2.roles << Role.find_by(name: 'coach')
coach3.roles << Role.find_by(name: 'coach')

coachs = [coach1, coach2, coach3]
# CREATE 3 ACADEMIES
kuerten = Academy.create!(name: 'Kuerten', manager: manager, coordinator: coordinator, annual: false)
kuerten_image = URI.open('https://res.cloudinary.com/dushuxqmj/image/upload/v1731177238/etendart_dev/ip1nfwajzofkglkbjmrh.jpg')
kuerten.image.attach(io: kuerten_image, filename: 'kuerten-court.jpg', content_type: 'image/jpg')

zidane = Academy.create!(name: 'Zidane', manager: manager, annual: true)
zidane_image = URI.open('https://res.cloudinary.com/dushuxqmj/image/upload/v1731177278/etendart_dev/orejbsdzmbzw4k9jkdqd.png')
zidane.image.attach(io: zidane_image, filename: 'zidane-court.jpg', content_type: 'image/jpg')

batum = Academy.create!(name: 'Batum', manager: manager, annual: false)
batum_image = URI.open('https://res.cloudinary.com/dushuxqmj/image/upload/v1731177238/etendart_dev/eateyetw2sgwy3bgnh17.avif')
batum.image.attach(io: batum_image, filename: 'batum-court.jpg', content_type: 'image/jpg')

# CREATE 2 LOCATIONS FOR EACH ACADEMY
Academy.all.each do |academy|
2.times do |i|
  Location.create!(
    name: ["Terrain", "Salle", "Bureau"].sample,
    address: Faker::Address.full_address,
    academy_id: academy.id
    )
  end
end

# CREATE 20 STUDENTS
20.times do |i|
  student = Student.new(
    first_name: Faker::Name.first_name,
    last_name: Faker::Name.last_name,
    gender: ['Garçon', 'Fille'].sample,
    email: Faker::Internet.email,
    date_of_birth: Faker::Date.birthday(min_age: 10, max_age: 18),
    phone_number: Faker::PhoneNumber.cell_phone,
    address: Faker::Address.full_address,
    zipcode: [92000, 75000, 69000, 13000, 31000].sample,
    allergy: rand < 0.8 ? nil : ["Arachides", "Lactose", "Gluten", "Oeufs"].sample,
    )
  # CREATE USERNAME FOR STUDENT FROM THEIR FIRST NAME, LAST NAME AND DATE OF BIRTH
  excel_serial_date = (student.date_of_birth - Date.new(1899, 12, 30)).to_i
  username = "#{student.first_name.downcase}#{student.last_name.downcase}#{excel_serial_date }"
  student.username = username
  student.save
  student.academies << kuerten
  student.academies << [zidane, batum].sample if i.even?
  student.memberships << Membership.create!(academy: [kuerten, zidane].sample, student: student, start_year: 2024, amount: 15, paid: rand < 0.7)
end

# MISE À JOUR DES PAID MEMBERSHIPS
payment_methods = ["cash", "cheque", "hello_asso"]
Membership.all.each do |membership|
  if membership.paid
    payment_method = rand < 0.95 ? payment_methods.sample : "offert"
    membership.update!(
      payment_method: payment_method,
      payment_date: Date.today - rand(1..100).days,
      receiver: ([coach1, coach2, coach3, manager, manager1, coordinator].sample if payment_method != "hello_asso")
      )
  end
end


school_period_names = ["Printemps", "Été", "Toussaint", "Février"]
camp_names = ["semaine1", "semaine2"]

# CREATE 2 PAST SCHOOL PERIODS WITH 2 CAMPS FOR EACH SCHOOL_PERIOD, AND 2 ACTIVITIES FOR EACH CAMP WITH 5 COURSES FOR EACH ACTIVITY (1 PER DAY)
#
# CREATE 2 SCHOOL PERIODS
2.times do |i|
  school_period = SchoolPeriod.create!(
    name: school_period_names[i],
    year: 2024,
    paid: i.even? ? true : false,
    academy_id: Academy.find_by(name: "Kuerten").id
    )
  school_period.update(price: 15) if school_period.paid
  # INSCRIPTION DES STUDENTS À LA SCHOOL PERIOD
  Student.all.each { |student| SchoolPeriodEnrollment.create!(student: student, school_period: school_period) }
  # CREATE 2 CAMPS THE SCHOOL PERIOD
  2.times do |i|
    camp = Camp.create!(
      name: camp_names[i],
      school_period: school_period,
      new: false,
      starts_at: Date.new(2024, 10, 7) + 7*i.days,
      ends_at: Date.new(2024, 10, 11) + 7*i.days
      )
    # INSCRIPTION DES STUDENTS AUX CAMPS
    Student.all.each { |student| CampEnrollment.create!(student: student, camp: camp, image_consent: rand < 0.9) }
    # MISE À JOUR DE LA PAIEMENT DES CAMPS
    camp_enrollments = CampEnrollment.where(camp: camp)
    camp_enrollments.each { |camp_enrollment| camp_enrollment.update(paid: rand < 0.95) if camp_enrollment.camp.school_period.paid }
    camp_enrollments.each { |camp_enrollment| camp_enrollment.update(payment_method: CampEnrollment::PAYMENT_METHODS.compact.reject { |method| method == "offert" }.sample, payment_date: (camp.starts_at..camp.ends_at).to_a.sample) if camp_enrollment.paid }
    camp_enrollments.each { |camp_enrollment| camp_enrollment.update(receiver: [coach1, coach2, coach3, manager, coordinator].sample) if camp_enrollment.paid && !["hello_asso", "virement", "pass"].include?(camp_enrollment.payment_method) }
    # CREATE 2 ACTIVITIES FOR EACH CAMP
    2.times do |j|
      category = Category.all.sample
      activity_name = generate_activity_name(category.name)
      coach = coachs.sample
      # Ensure unique activity names within the same camp
      used_activity_names = camp.activities.pluck(:name)
      while used_activity_names.include?(activity_name)
        activity_name = generate_activity_name(category.name)
      end
      activity = Activity.create!(
        name: activity_name,
        coach: coach,
        camp: camp,
        category: category,
        location: camp.academy.locations.sample
        )
      # INSCRIPTION DES STUDENTS AUX ACTIVITÉS
      Student.all.each { |student| ActivityEnrollment.create!(student: student, activity: activity) }
      coach.academies_as_coach << camp.academy unless coach.academies_as_coach.include?(camp.academy)
      coach.categories << category unless coach.categories.include?(category)
      coach.camps << camp unless coach.camps.include?(camp)
      activity.coaches << coach
      # CREATE 5 COURSES FOR EACH ACTIVITY, THE FIRST ONE STARTING ON MONDAY OF THE CAMP
      start_hour = rand(10..16)
      5.times do |k|
        start_day = camp.starts_at + k.days
        start = start_day + start_hour.hour
        course = Course.create!(
          starts_at: start,
          ends_at: start + 2.hour,
          activity: activity,
          manager: manager,
          coach: activity.coach,
          status: true
          )
        # INSCRIPTION DES STUDENTS AUX COURSES, ET MISE À JOUR DE LA PRÉSENCE ALÉATOIRE
        Student.all.each { |student| CourseEnrollment.create!(student: student, course: course, present: rand < 0.9) }
      end
    end
  end
end

# CREATE A NEW SCHOOL PERIOD WITH TWO CAMPS
new_school_period = SchoolPeriod.create!(
  name: "Février",
  year: 2024,
  paid: true,
  academy: kuerten
)
new_school_period.update(price: 15) if new_school_period.paid

# INSCRIPTION DES STUDENTS À LA NOUVELLE SCHOOL PERIOD
Student.all.each { |student| SchoolPeriodEnrollment.create!(student: student, school_period: new_school_period) }

# CREATE 2 CAMPS FOR THE NEW SCHOOL PERIOD
starts_at = Date.current.beginning_of_week
2.times do |i|
  camp = Camp.create!(
    name: "semaine#{i + 1}",
    school_period: new_school_period,
    starts_at: starts_at + 7 * i.days,
    ends_at: starts_at + 4.day + 7 * i.days
  )
  # INSCRIPTION DES STUDENTS AUX CAMPS
  Student.all.each { |student| CampEnrollment.create!(student: student, camp: camp, image_consent: rand < 0.9) }
  camp_enrollments = CampEnrollment.where(camp: camp)
  if camp.starts_at <= Date.current
    camp_enrollments.each do |camp_enrollment|
      camp_enrollment.update(paid: rand < 0.75)
      if camp_enrollment.paid
        camp_enrollment.update(payment_method: CampEnrollment::PAYMENT_METHODS.compact.sample, payment_date: (camp.starts_at - 20.day..Date.current).to_a.sample)
        camp_enrollment.update(receiver: [coach1, coach2, coach3, manager, coordinator].sample) if !["hello_asso", "virement", "pass", nil].include?(camp_enrollment.payment_method)
      end
    end
  else
    camp_enrollments.each do |camp_enrollment|
      camp_enrollment.update(paid: rand < 0.3)
      if camp_enrollment.paid
        camp_enrollment.update(payment_method: ["virement", "virement", "virement", "pass", "hello_asso"].sample, payment_date: (camp.starts_at - 20.day..Date.current).to_a.sample)
      end
    end
  end
  # CREATE 2 ACTIVITIES FOR EACH CAMP
  3.times do |j|
    category = Category.all.sample
    activity_name = generate_activity_name(category.name)
    coach = coachs.sample
    # Ensure unique activity names within the same camp
    used_activity_names = camp.activities.pluck(:name)
    while used_activity_names.include?(activity_name)
      activity_name = generate_activity_name(category.name)
    end
    activity = Activity.create!(
      name: activity_name,
      coach: coach,
      camp: camp,
      category: category,
      location: camp.academy.locations.sample
    )
    # INSCRIPTION DES STUDENTS AUX ACTIVITÉS
    Student.all.each { |student| ActivityEnrollment.create!(student: student, activity: activity) }
    coach.academies_as_coach << camp.academy unless coach.academies_as_coach.include?(camp.academy)
    coach.categories << category unless coach.categories.include?(category)
    coach.camps << camp unless activity.coach.camps.include?(camp)
    activity.coaches << coach
    # CREATE 5 COURSES FOR EACH ACTIVITY, THE FIRST ONE STARTING ON MONDAY OF THE CAMP
    start_hour = j.even? ? 10 : 13
    5.times do |k|
      start_day = camp.starts_at + k.days
      start = start_day + start_hour.hour
      course = Course.create!(
        starts_at: start,
        ends_at: start + 2.hour,
        activity: activity,
        manager: manager,
        coach: activity.coach,
        status: (true if start + 2.hour <= Time.current)
        )
      # INSCRIPTION DES STUDENTS AUX COURSES
      Student.all.each { |student| CourseEnrollment.create!(student: student, course: course, present: (course.status ? rand < 0.9 : true )) }
    end
  end
end

# MISE A JOUR DE LA PRESENCE DES STUDENTS POUR ACTIVITY_ENROLLMENTS, CAMP_ENROLLMENTS ET SCHOOL_PERIOD_ENROLLMENTS
# MISE A JOUR DE LA PRESENCE DES STUDENTS POUR ACTIVITY_ENROLLMENTS, CAMP_ENROLLMENTS ET SCHOOL_PERIOD_ENROLLMENTS
Student.all.each do |student|
  # if student == Student.first
  #   student.course_enrollments.update_all(present: false)
  # end
  school_period_enrollments = student.school_period_enrollments
  school_period_enrollments.each do |school_period_enrollment|
    school_period = school_period_enrollment.school_period
    course_enrollments = student.course_enrollments.joins(course: :activity).where('activities.camp_id IN (?) AND courses.starts_at < ?', school_period.camps.pluck(:id), Time.current)
    if course_enrollments.any? { |course_enrollment| course_enrollment.present }
      school_period_enrollment.update(present: true)
    end
  end

  camp_ids = student.camps.pluck(:id)
  camp_enrollments = student.camp_enrollments
  camp_enrollments.each do |camp_enrollment|
    camp = camp_enrollment.camp
    course_enrollments = student.course_enrollments.joins(course: :activity).where('activities.camp_id = ? AND courses.starts_at < ?', camp.id, Time.current)
    if course_enrollments.any? { |course_enrollment| course_enrollment.present }
      camp_enrollment.update(present: true)
    end
  end

  activity_enrollments = student.activity_enrollments.joins(:activity).where('activities.camp_id IN (?)', camp_ids)
  activity_enrollments.each do |activity_enrollment|
    activity = activity_enrollment.activity
    course_enrollments = student.course_enrollments.joins(course: :activity).where('activities.id = ? AND courses.starts_at < ?', activity.id, Time.current)
    if course_enrollments.any? { |course_enrollment| course_enrollment.present }
      activity_enrollment.update(present: true)
    end
  end
end


# CREATE 1 ANNUAL PROGRAM WITH 5 PROGRAM PERIODS
annual_program = AnnualProgram.create!(academy: zidane)

program_periods_defaults = [
  { start_date: Date.parse("16/09/2024"), end_date: Date.parse("18/10/2024") },
  { start_date: Date.parse("28/10/2024"), end_date: Date.parse("13/12/2024") },
  { start_date: Date.parse("06/01/2025"), end_date: Date.parse("14/02/2025") },
  { start_date: Date.parse("03/03/2025"), end_date: Date.parse("11/04/2025") },
  { start_date: Date.parse("21/04/2025"), end_date: Date.parse("13/06/2025") }
]

# CREATE 5 PROGRAM PERIODS FOR THE ANNUAL PROGRAM
program_periods_defaults.each do |period_params|
  annual_program.program_periods << ProgramPeriod.create!(start_date: period_params[:start_date], end_date: period_params[:end_date], annual_program: annual_program)
end

annual_program.update(starts_at: annual_program.program_periods.first.start_date)
annual_program.update(ends_at: annual_program.program_periods.last.end_date)

# INSCRIPTION DES STUDENTS À L'ANNUAL PROGRAM
Student.all.each do |student|
  student.academies << zidane unless student.academies.include?(zidane)
  AnnualProgramEnrollment.create!(student: student, annual_program: annual_program, image_consent: rand < 0.8)
end

# CREATE 5 ACTIVITIES FOR THE ANNUAL PROGRAM
# EACH ACTIVITY HAS 1 COURSE PER WEEK, EVERY WEEK WITHIN THE PROGRAM PERIODS

5.times do |i|
  category = Category.all.sample
  activity_name = generate_activity_name(category.name)
  coach = coachs.sample
  used_activity_names = annual_program.activities.pluck(:name)
  while used_activity_names.include?(activity_name)
    activity_name = generate_activity_name(category.name)
  end
  activity = Activity.create!(
    name: activity_name,
    coach: coach,
    annual_program: annual_program,
    category: category,
    location: zidane.locations.sample
  )
  coach.academies_as_coach << zidane unless coach.academies_as_coach.include?(zidane)
  coach.categories << category unless coach.categories.include?(category)
  coach.activities << activity unless coach.activities.include?(activity)
  activity.coaches << coach unless activity.coaches.include?(coach)

  # INSCRIPTION DES STUDENTS AUX ACTIVITÉS
  Student.all.each { |student| ActivityEnrollment.create!(student: student, activity: activity) }

  # CREATE 1 COURSE PER WEEK FOR EACH ACTIVITY
  start_hour = rand(16..19)
  annual_program.program_periods.each do |program_period|
    program_period_start = program_period.start_date
    program_period_end = program_period.end_date
    weeks = ((program_period_end - program_period_start).to_i / 7) + 1
    weeks.times do |j|
      start_day = program_period_start + i.days + j.weeks
      start = start_day + start_hour.hour
      course = Course.create!(
        starts_at: start,
        ends_at: start + 2.hour,
        activity: activity,
        manager: manager,
        coach: activity.coach,
        annual: true
      )
      # INSCRIPTION DES STUDENTS AUX COURSES
      if course.starts_at <= Date.today
        course.update(status: true)
        Student.all.each { |student| CourseEnrollment.create!(student: student, course: course, present: rand < 0.7) }
      else
        Student.all.each { |student| CourseEnrollment.create!(student: student, course: course) }
      end
    end
  end
end

# MISE A JOUR DE LA PRESENCE DES STUDENTS POUR ACTIVITY_ENROLLMENTS ET ANNUAL_PROGRAM_ENROLLMENTS

Student.all.each do |student|
  annual_program_enrollment = student.annual_program_enrollments.find_by(annual_program: annual_program)
  course_enrollments = student.course_enrollments.joins(course: :activity).where('activities.annual_program_id = ? AND courses.starts_at < ?', annual_program.id, Time.current)
  if course_enrollments.any? { |course_enrollment| course_enrollment.present }
    annual_program_enrollment.update(present: true)
  end
  activity_enrollments = student.activity_enrollments.joins(:activity).where('activities.annual_program_id = ?', annual_program.id)
  activity_enrollments.each do |activity_enrollment|
    activity = activity_enrollment.activity
    course_enrollments = student.course_enrollments.joins(course: :activity).where('activities.id = ? AND courses.starts_at < ?', activity.id, Time.current)
    if course_enrollments.any? { |course_enrollment| course_enrollment.present }
      activity_enrollment.update(present: true)
    end
  end
end

# CREATE STATS FOR ACTIVITIES, CAMPS, SCHOOL PERIODS AND ANNUAL PROGRAMS

UpdateActivityStatsJob.perform_now
UpdateCampStatsJob.perform_now
UpdateSchoolPeriodStatsJob.perform_now
UpdateAnnualProgramStatsJob.perform_now

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
