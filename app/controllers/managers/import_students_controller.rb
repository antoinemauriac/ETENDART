class Managers::ImportStudentsController < ApplicationController

  def import
    camp = Camp.find(params[:camp][:camp_id])
    authorize([:managers, camp], policy_class: Managers::StudentPolicy)
    school_period = camp.school_period
    academy = camp.academy
    file = params[:camp][:csv_file]
    file = File.open(file)

    start_year = camp.starts_at.month >= 4 ? camp.starts_at.year : camp.starts_at.year - 1
    students = camp.students.to_a

    ActiveRecord::Base.transaction do

      school_period.school_period_enrollments.each do |school_period_enrollment|
        camps = school_period_enrollment.student.camps.where(school_period: school_period)
        if camps == [camp] || camps.empty?
          school_period_enrollment.destroy
        end
      end

      camp.camp_enrollments.destroy_all
      ActivityEnrollment.joins(:activity).where('activities.camp_id = ?', camp.id).destroy_all
      CourseEnrollment.joins(course: :activity).where('activities.camp_id = ?', camp.id).destroy_all


      students.each do |student|
        student.destroy if student.courses.empty?
        courses_during_civil_year = student.courses.where('starts_at >= ? AND starts_at <= ?', Date.new(start_year, 4, 1), Date.new(start_year + 1, 8, 31))
        membership = student.memberships.find_by(start_year: start_year)
        if courses_during_civil_year.empty? && membership && membership.status == false
          membership&.destroy
        end
      end

      CSV.foreach(file, headers: true, col_sep: ';') do |row|
        row = row.to_hash
        if row['prénom'].nil? || row['nom'].nil? || row['date-naissance'].nil? || row['username'].nil? || row['genre'].nil?
          flash[:alert] = "Le 'prénom', le 'nom', la 'date de naissance' et le 'username' doivent être présents pour chaque élève"
          redirect_to managers_camp_path(camp) and return
        else
          username = row['username'].to_s.strip.downcase.gsub(/\s+/, '')

          student = Student.where("lower(unaccent(username)) = unaccent(?)", username).first_or_initialize
          student.assign_attributes(student_params_upload(row))

          if student.new_record?
            student.save
          else
            student.update(student_params_upload(row))
          end

          student.academies << academy unless student.academies.include?(academy)
          student.school_periods << school_period unless student.school_periods.include?(school_period)

          # vérifier si le student à un school_period_enrollment avec un tshirt_delivered à true
          if school_period.tshirt == true
            school_period_enrollments = student.school_period_enrollments
                                               .joins(:school_period)
                                               .where(school_periods: { academy_id: academy.id })

            school_period_enrollment = student.school_period_enrollments.find_by(school_period: school_period)
            if school_period_enrollments.any? { |school_period_enrollment| school_period_enrollment.tshirt_delivered == true }
              school_period_enrollment.update(tshirt_delivered: true)
            end
          end

          CampEnrollment.create(student: student, camp: camp, image_consent: row['droitimage'] == 'oui' ? true : false)

          (1..3).each do |i|
            activity_name = row["activite_#{i}"]
            next unless activity_name.present?

            activity = camp.activities.find_by(name: activity_name)
            if activity.present?
              student.activities << activity
              student.courses << activity.courses
            else
              flash[:alert] = "Une erreur est survenue. L'activité '#{activity_name}' ne correspond pas à une activité créée sur l'application"
              redirect_to managers_camp_path(camp) and return
            end
          end

          membership = student.memberships.find_by(start_year: start_year)
          if membership.nil?
            membership = student.memberships.create(amount: 15, start_year: start_year, academy: student.main_academy)
          end

          if !["cash", "cheque", "hello_asso", "offert", "virement", "pass", nil].include?(row['cotisation'])
            flash[:alert] = "Le mode de paiement de la cotisation doit être cash, cheque, hello_asso, offert, pass ou virement"
            redirect_to managers_camp_path(camp) and return
          end
          if %w[cash cheque hello_asso offert virement pass].include?(row['cotisation']) && membership.status == false
            membership.update(status: true, payment_method: row['cotisation'], payment_date: Date.current, receiver_id: current_user.id)
          end
        end
      end
      redirect_to managers_camp_path(camp), notice: "Le fichier CSV a été importé avec succès."
    end
  end

  private

  def student_params_upload(row)
    row = row.transform_keys do |key|
      case key
      when 'prénom'
        'first_name'
      when 'nom'
        'last_name'
      when 'date-naissance'
        'date_of_birth'
      when 'genre'
        'gender'
      when 'tel'
        'phone_number'
      when 'ville'
        'city'
      when 'cp'
        'zipcode'
      when 'adresse'
        'address'
      when 'allergies'
        'allergy'
      else
        key
      end
    end

    ActionController::Parameters.new(row).permit(:username, :first_name, :last_name, :email, :date_of_birth, :gender, :phone_number, :city, :zipcode, :address, :allergy)
  end
end
