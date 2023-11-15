class Managers::ImportAnnualStudentsController < ApplicationController
  def import
    annual_program = AnnualProgram.find(params[:annual_program])
    academy = annual_program.academy
    authorize([:managers, annual_program], policy_class: Managers::ImportAnnualStudentsPolicy)
    file = params[:academy][:csv_file]
    file = File.open(file)
    csv = CSV.parse(file, headers: true, col_sep: ';')

    annual_program.annual_program_enrollments.destroy_all

    annual_program.activities.each do |activity|
      activity.activity_enrollments.destroy_all
    end

    annual_program.courses.each do |course|
      course.course_enrollments.destroy_all
    end

    annual_program.students.each do |student|
      student.destroy if student.courses.empty?
    end

    # vérifier que chaque champ prénom, nom et date-naissance n'est pas empty
    csv.each do |row|
      row = row.to_hash
      first_name = row['prénom']
      last_name = row['nom']
      date_of_birth = row['date-naissance']
      username = row['username']
      if first_name.nil? || last_name.nil? || date_of_birth.nil? || username.nil?
        flash[:alert] = "Le 'prénom', le 'nom', la 'date de naissance' et le 'username' doivent être présents pour chaque élève"
        redirect_to managers_annual_program_path(annual_program) and return
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
      student.annual_programs << annual_program unless student.annual_programs.include?(annual_program)

      (1..3).each do |i|
        activity_name = row["activite_#{i}"]
        if activity_name.present?
          activity = annual_program.activities.find_by(name: activity_name)
          if activity.present?
            student.activities << activity
            student.courses << activity.courses
          else
            flash[:alert] = "Une erreur est survenue. L'activité '#{activity_name}' ne correspond pas à une activité créée sur l'application"
            redirect_to managers_annual_program_path(annual_program) and return
          end
        end
      end
    end

    redirect_to managers_annual_program_path(annual_program), notice: "Le fichier CSV a été importé avec succès."
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
