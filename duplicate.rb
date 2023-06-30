# students_with_same_email = Student.group(:email).having('COUNT(email) > 1').pluck(:email)

# students_with_same_email.each do |email|
#   students = Student.where(email: email)
#   puts "Students with email #{email}:"
#   students.each do |student|
#     puts "- #{student.first_name} #{student.last_name}"
#   end
#   puts "-----------------------"
# end




# identifier le main student et le duplicate

# # main = Student.find(1)
# # duplicate = Student.find(2)


duplicate.academy_enrollments.where.not(academy_id: main.academies.ids).update_all(student_id: main.id)
duplicate.school_period_enrollments.where.not(school_period_id: main.school_periods.ids).update_all(student_id: main.id)
duplicate.camp_enrollments.where.not(camp_id: main.camps.ids).update_all(student_id: main.id)
duplicate.activity_enrollments.where.not(activity_id: main.activities.ids).update_all(student_id: main.id)
duplicate.course_enrollments.where.not(course_id: main.courses.ids).update_all(student_id: main.id)
duplicate.feedbacks.where.not(id: main.feedbacks.ids).update_all(student_id: main.id)
