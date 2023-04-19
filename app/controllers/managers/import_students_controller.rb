class Managers::ImportStudentsController < ApplicationController

  def import
    school_period = SchoolPeriod.find(params[:school_period][:school_period_id])
    authorize([:managers, school_period], policy_class: Managers::StudentPolicy)
    academy = school_period.academy
    file = params[:school_period][:csv_file]
    file = File.open(file)
    csv = CSV.parse(file, headers: true, col_sep: ';')

    csv.each do |row|
      row = row.to_hash
      student = Student.where("lower(unaccent(replace(username, ' ', ''))) = unaccent(?)", row['username'].downcase.gsub(/\s+/, '')).first_or_initialize


      # student = Student.where("lower(unaccent(username)) = unaccent(?)", row['username'].downcase.strip).first_or_initialize
      # student = Student.where("replace(lower(unaccent(username)), ' ', '') = unaccent(?)", row['username'].downcase.strip).first_or_initialize

      student.assign_attributes(student_params_upload(row))

      if student.new_record?
        student.save
      else
        student.update(student_params_upload(row))
      end

      # retirer l'élève des cours de la période

      student.school_period_enrollments.where(school_period: school_period).destroy_all
      student.camp_enrollments.joins(:camp).where(camps: { school_period: school_period }).destroy_all
      student.activity_enrollments.joins(activity: :camp).where(camps: { school_period: school_period }).destroy_all
      student.course_enrollments.joins(course: { activity: :camp }).where(camps: { school_period: school_period }).destroy_all

      student.academies << academy unless student.academies.include?(academy)
      student.school_periods << school_period

      if school_period.camps.any?
        (1..4).each do |week_number|
          week_name = "semaine#{week_number}"
          if row[week_name] == "oui"
            week_camp = school_period.camps.find_by(name: week_name)
            if week_camp.present?
              student.camps << week_camp

              (1..2).each do |i|
                activity_name = row["activite_#{i}_#{week_name}"]
                if activity_name.present?
                  activity = week_camp.activities.find_by(name: activity_name)
                  if activity.present?
                    student.activities << activity
                    student.courses << activity.courses
                  else
                    flash[:alert] = "Une erreur est survenue. L'activité #{activity_name} ne correspond pas à une activité créée sur l'application"
                    redirect_to managers_school_period_path(school_period) and return
                  end
                end
              end
            else
              flash[:alert] = "Une erreur est survenue. La semaine #{week_name} ne correspond pas à une semaine créée sur l'application"
              redirect_to managers_school_period_path(school_period) and return
            end
          end
        end
      else
        flash[:alert] = "Vous devez d'abord créer les semaines et les activités du stage avant d'importer le csv"
        redirect_to managers_school_period_path(school_period) and return
      end
    end

    redirect_to managers_school_period_path(school_period), notice: "Le fichier CSV a été importé avec succès."
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
      else
        key
      end
    end

    row['first_name'] = row['first_name'].capitalize if row['first_name'].present?
    row['last_name'] = row['last_name'].capitalize if row['last_name'].present?

    ActionController::Parameters.new(row).permit(:username, :first_name, :last_name, :email, :date_of_birth, :gender, :phone_number, :city, :zipcode, :address)
  end
end
