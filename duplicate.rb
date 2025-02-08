# identifier le main student et le duplicate

# main = Student.find(878)
# duplicate = Student.find(2998)

# if duplicate.photo.attached? && !main.photo.attached?
#   main.photo.attach(duplicate.photo.blob)
# end

# duplicate.academy_enrollments.where.not(academy_id: main.academies.ids).update_all(student_id: main.id)
# duplicate.annual_program_enrollments.where.not(annual_program_id: main.annual_programs.ids).update_all(student_id: main.id)
# duplicate.school_period_enrollments.where.not(school_period_id: main.school_periods.ids).update_all(student_id: main.id)
# duplicate.camp_enrollments.where.not(camp_id: main.camps.ids).update_all(student_id: main.id)
# duplicate.activity_enrollments.where.not(activity_id: main.activities.ids).update_all(student_id: main.id)
# duplicate.course_enrollments.where.not(course_id: main.courses.ids).update_all(student_id: main.id)
# duplicate.feedbacks.where.not(id: main.feedbacks.ids).update_all(student_id: main.id)
# duplicate.memberships.where(paid: true).where.not(id: main.memberships.ids).update_all(student_id: main.id)
# duplicate.destroy

# students_with_same_email = Student.group(:email).having('COUNT(email) > 1').pluck(:email)

# students_with_same_email.each do |email|
#   students = Student.where(email: email)
#   puts "Students with email #{email}:"
#   students.each do |student|
#     puts "- #{student.first_name} #{student.last_name}"
#   end
#   puts "-----------------------"
# end

# students with same first_name last_name pair
# students_with_duplicates = Student
#   .select('LOWER(first_name) AS first_name, LOWER(last_name) AS last_name, COUNT(*) AS count, phone_number')
#   .group('first_name, last_name, phone_number')
#   .having('COUNT(*) > 1')
#   .order('first_name, last_name, phone_number')
#   .map do |student|
#     students_with_same_name = Student
#       .where('LOWER(first_name) = ? AND LOWER(last_name) = ? AND phone_number = ?', student.first_name, student.last_name, student.phone_number)
#       .pluck(:id, :first_name, :last_name)
#       .map { |s| "#{s[1]} #{s[2]} (id #{s[0]})" }
#       .join(" et ")
#     full_name = "#{student.first_name.capitalize} #{student.last_name.capitalize}" # Nom complet
#     tel_info = "tel : #{student.phone_number}" # Informations sur le téléphone

#     {
#       full_name: "#{full_name} (#{students_with_same_name}) #{tel_info}",
#       students: students_with_same_name
#     }
#   end

# Student.select(:first_name, :last_name)
#        .group(:first_name, :last_name)
#        .having('COUNT(*) > 1')
#        .each do |student|
#   duplicates = Student.where(first_name: student.first_name, last_name: student.last_name)
#   puts "#{student.first_name} #{student.last_name}:"
#   duplicates.each_with_index do |duplicate, index|
#     puts "#{index + 1} - ID : #{duplicate.id} - Date de naissance: #{duplicate.date_of_birth}, Phone Number: #{duplicate.phone_number}"
#   end
# end



# students = Student.where(username: nil).order(:created_at)

# students.each do |student|
  # first_name = student.first_name.downcase
  # last_name = student.last_name.downcase
  # excel_serial_date = (student.date_of_birth - Date.new(1899, 12, 30)).to_i

  # username = "#{first_name}#{last_name}#{excel_serial_date }"
  # student.update(username: username)
# end

# CSV.open("students_duplicates.csv", "wb") do |csv|
#   # En-têtes pour le fichier CSV
#   csv << ["First-name / Last-name", "ID", "Date-of_birth", "Phone_number"]

#   # Votre requête existante
#   Student.select(:first_name, :last_name)
#          .group(:first_name, :last_name)
#          .having('COUNT(*) > 1')
#          .each do |student|
#     duplicates = Student.where(first_name: student.first_name, last_name: student.last_name)

#     duplicates.each do |duplicate|
#       # Écrire chaque doublon dans le fichier CSV
#       csv << ["#{duplicate.first_name} #{duplicate.last_name}", duplicate.id, duplicate.date_of_birth, duplicate.phone_number]
#     end
#   end
# end


# itérer sur les les camp_enrollments du student
# pour chaque camp_enrollment
# compter le nombre d'activity_enrollments associés
# si le nombre d'activity_enrollments est égal à 0
# compter le nombre de attended course_enrollments associés au camp_enrollment
# si le nombre de course_enrollments attended est égal à 0
# supprimer le camp_enrollment
# fin


# SUPPRESSION DES CAMP ENROLLMENTS SANS ACTIVITY ENROLLMENTS NI COURSE ENROLLMENTS ATTENDED

# student = Student.find(1186)
# student.camp_enrollments.each do |camp_enrollment|
#   camp = camp_enrollment.camp
#   activity_enrollments = student.activity_enrollments.joins(:activity).where(activities: { camp_id: camp.id })
#   activity_enrollments_count = activity_enrollments.count

#   if activity_enrollments_count == 0
#     attended_course_enrollments_count = student.course_enrollments.joins(course: :activity).where(activities: { camp_id: camp.id }).attended.count

#     if attended_course_enrollments_count == 0
#       puts "SchoolPeriod: #{camp.school_period.full_name} Camp enrollment : #{camp_enrollment.camp.name} - Académie : #{camp.academy.name} will be destroyed"
#     end
#   end
# end
