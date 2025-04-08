class Managers::ImportAnnualStudentsController < ApplicationController
  def import
    annual_program = AnnualProgram.find(params[:annual_program])
    academy = annual_program.academy
    authorize([:managers, annual_program], policy_class: Managers::ImportAnnualStudentsPolicy)
    file = params[:academy][:csv_file]
    file = File.open(file)

    first_line = file.readline
    detected_col_sep = first_line.include?(';') ? ';' : ','
    file.rewind

    start_year = annual_program.starts_at.year

    ActiveRecord::Base.transaction do

      annual_program.annual_program_enrollments.destroy_all

      annual_program.activities.each do |activity|
        activity.activity_enrollments.destroy_all
      end

      annual_program.courses.each do |course|
        course.course_enrollments.destroy_all
      end

      CSV.foreach(file, headers: true, col_sep: detected_col_sep) do |row|
        row = row.to_hash
        if row['prénom'].nil? || row['nom'].nil? || row['date-naissance'].nil? || row['username'].nil? || row['genre'].nil?
          flash[:alert] = "Le 'prénom', le 'nom', la 'date de naissance' et le 'username' doivent être présents pour chaque élève"
          redirect_to managers_annual_program_path(annual_program) and return
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
          AnnualProgramEnrollment.create(student: student, annual_program: annual_program, image_consent: row['droitimage'] == 'oui' ? true : false)

          (1..3).each do |i|
            activity_name = row["activite_#{i}"]
            if activity_name.present?
              activity = annual_program.activities.where("unaccent(lower(name)) = unaccent(lower(?))", activity_name).first
              if activity.present?
                ActivityEnrollment.create(student: student, activity: activity, confirmed: true)
                student.courses << activity.courses
              else
                flash[:alert] = "Une erreur est survenue. L'activité '#{activity_name}' ne correspond pas à une activité créée sur l'application"
                redirect_to managers_annual_program_path(annual_program) and return
              end
            end
          end

          student.activity_enrollments.where(activity: annual_program.activities).update_all(confirmed: true)

          membership = student.memberships.find_by(start_year: start_year)
          if membership.nil?
            membership = Membership.create(student: student, amount: Membership::PRICE, start_year: start_year, academy: academy)
          end

          if !Membership::PAYMENT_METHODS.include?(row['cotisation'])
            flash[:alert] = "Le mode de paiement de la cotisation doit être cash, cheque, hello_asso, offert, pass ou virement"
            redirect_to managers_annual_program_path(annual_program) and return
          end
          if Membership::PAYMENT_METHODS.compact.include?(row['cotisation']) && membership.paid == false
            membership.update(paid: true, payment_method: row['cotisation'], payment_date: Date.current, receiver_id: current_user.id)
          end
        end
      end
      redirect_to managers_annual_program_path(annual_program), notice: "Le fichier CSV a été importé avec succès."
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
