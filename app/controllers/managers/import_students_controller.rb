class Managers::ImportStudentsController < ApplicationController

  def import
    camp = Camp.find(params[:camp][:camp_id])
    authorize([:managers, camp], policy_class: Managers::StudentPolicy)
    school_period = camp.school_period
    academy = camp.academy
    file = params[:camp][:csv_file]
    file = File.open(file)

    school_period.school_period_enrollments.each do |school_period_enrollment|
      camps = school_period_enrollment.student.camps.where(school_period: school_period)
      if camps == [camp] || camps.empty?
        school_period_enrollment.destroy
      end
    end

    camp.camp_enrollments.destroy_all
    ActivityEnrollment.joins(:activity).where('activities.camp_id = ?', camp.id).destroy_all
    CourseEnrollment.joins(course: :activity).where('activities.camp_id = ?', camp.id).destroy_all

    ActiveRecord::Base.transaction do
      CSV.foreach(file, headers: true, col_sep: ';') do |row|
        row = row.to_hash
        if row['prénom'].nil? || row['nom'].nil? || row['date-naissance'].nil? || row['username'].nil?
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
