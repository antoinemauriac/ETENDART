class Day < ApplicationRecord
  belongs_to :activity

  # def self.import_stages_csv(file_path)
  #   ActiveRecord::Base.transaction do
  #     CSV.foreach(file_path, headers: true, col_sep: ';') do |row|
  #       data = row.to_h
  #       data = data.transform_keys { |key| key.gsub(/^\uFEFF/, '') }

  #       academy = Academy.find_by(name: data['academie'])
  #       school_period = SchoolPeriod.find_or_create_by(name: data['stage'], year: data['annee'], academy_id: academy.id, new: false)
  #       camp = Camp.find_or_create_by(name: data['semaine'], school_period: school_period, starts_at: data['debut'], ends_at: data['fin'])
  #       activity = Activity.find_or_create_by(name: data['activite'], camp: camp, category: Category.find_by(name: data['categorie']), location: academy.locations.sample)

  #       starts_at = camp.starts_at
  #       start_time = Time.parse('10:00') # Heure de début, par exemple, 10:00 AM
  #       end_time = Time.parse('12:00')   # Heure de fin, par exemple, 12:00 PM
  #       interval = (camp.ends_at - camp.starts_at).to_i

  #       # Crée 5 cours, un pour chaque jour de la semaine
  #       (0..interval).each do |day|
  #         date = starts_at + day.days
  #         start_datetime = Time.zone.local(date.year, date.month, date.day, start_time.hour, start_time.min, start_time.sec)
  #         end_datetime = Time.zone.local(date.year, date.month, date.day, end_time.hour, end_time.min, end_time.sec)
  #         Course.find_or_create_by(
  #           activity: activity,
  #           starts_at: start_datetime,
  #           ends_at: end_datetime,
  #           manager: academy.manager
  #         )
  #       end
  #     end
  #   end
  # end

  # def self.import_students_csv(file_path)
  #   ActiveRecord::Base.transaction do
  #     CSV.foreach(file_path, headers: true, col_sep: ',') do |row|
  #       data = row.to_h
  #       data = data.transform_keys { |key| key.gsub(/^\uFEFF/, '') }

  #       username = data['username'].to_s.strip.downcase.gsub(/\s+/, '')
  #       student = Student.where("lower(unaccent(username)) = unaccent(?)", username).first_or_initialize

  #       if student.new_record?
  #         student.assign_attributes(
  #           first_name: data['prénom'],
  #           last_name: data['nom'],
  #           date_of_birth: data['date-naissance'],
  #           username: username,
  #           email: data['email'],
  #           gender: data['genre'],
  #           phone_number: data['telephone'],
  #           address: data['adresse'],
  #           zipcode: data['codepostal'],
  #           city: data['ville']
  #         )
  #         student.save!
  #       end

  #       academy = Academy.find_by(name: data['academie'])
  #       school_period = SchoolPeriod.find_by(name: data['stage'], year: data['annee'], academy_id: academy.id)
  #       camp = Camp.find_by(name: data['semaine'], school_period: school_period)

  #       student.academies << academy unless student.academies.include?(academy)
  #       student.school_periods << school_period unless student.school_periods.include?(school_period)
  #       student.camps << camp unless student.camps.include?(camp)
  #     end
  #   end
  # end
end
