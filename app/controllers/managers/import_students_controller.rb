class Managers::ImportStudentsController < ApplicationController

  def import
    camp = Camp.find(params[:camp][:camp_id])
    authorize([:managers, camp], policy_class: Managers::StudentPolicy)
    school_period = camp.school_period
    academy = camp.academy
    file = params[:camp][:csv_file]
    file = File.open(file)
    csv = CSV.parse(file, headers: true, col_sep: ';')

    ActiveRecord::Base.transaction do
      school_period.school_period_enrollments.each do |school_period_enrollment|
        camps = school_period_enrollment.student.camps.where(school_period: school_period)
        if camps == [camp] || camps.empty?
          school_period_enrollment.destroy
        end
      end

      camp.camp_enrollments.destroy_all
      ActivityEnrollment.joins(activity: :camp).where(camps: { id: camp.id }).destroy_all
      CourseEnrollment.joins(course: { activity: :camp }).where(camps: { id: camp.id }).destroy_all

      csv.each do |row|
        row = row.to_hash
        first_name = row['prénom']
        last_name = row['nom']
        date_of_birth = row['date-naissance']
        username = row['username']
        if first_name.nil? || last_name.nil? || date_of_birth.nil? || username.nil?
          flash[:alert] = "Le 'prénom', le 'nom', la 'date de naissance' et le 'username' doivent être présents pour chaque élève"
          redirect_to managers_camp_path(camp) and return
        end
      end

      csv.each do |row|
        row = row.to_hash
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
        student.camps << camp unless student.camps.include?(camp)

        (1..3).each do |i|
          activity_name = row["activite_#{i}"]
          if activity_name.present?
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
