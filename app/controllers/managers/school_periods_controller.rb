class Managers::SchoolPeriodsController < ApplicationController

  def index
    @academy = Academy.find(params[:academy])
    @school_periods = @academy.school_periods.sort_by(&:year)
    @school_period = SchoolPeriod.new
    skip_policy_scope
    authorize([:managers, @school_periods], policy_class: Managers::SchoolPeriodPolicy)
  end

  def create
    @academy = Academy.find(params[:academy])
    @school_period = @academy.school_periods.build(school_period_params)
    authorize([:managers, @school_period])
    if @school_period.save
      redirect_to managers_school_periods_path(academy: @academy)
      flash[:notice] = "Période scolaire créée"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @school_period = SchoolPeriod.find(params[:id])
    @academy = @school_period.academy
    authorize([:managers, @school_period])
    @camp = Camp.new

    @activities = @school_period.activities.order(:camp_id)
    @camps = @school_period.camps.order(:starts_at)
    @sorted_departments = @school_period.participant_departments.sort_by do |department|
      -@school_period.number_of_students_by_department(department)
    end
    @categories = @school_period.categories.uniq.sort_by { |category| @school_period.number_of_students_by_category(category) }.reverse
  end

  def statistics
    @school_period = SchoolPeriod.find(params[:id])
    authorize([:managers, @school_period])

    @academy = @school_period.academy
    @activities = @school_period.activities.order(:camp_id)
    @camps = @school_period.camps.order(:starts_at)
    @sorted_departments = @school_period.participant_departments.sort_by do |department|
      -@school_period.number_of_students_by_department(department)
    end
    @categories = @school_period.categories.uniq.sort_by { |category| @school_period.number_of_students_by_category(category) }.reverse
  end

  def destroy
    @school_period = SchoolPeriod.find(params[:id])
    @academy = @school_period.academy
    authorize([:managers, @school_period])
    @school_period.destroy
    redirect_to managers_school_periods_path(academy: @academy)
    flash[:notice] = "Période scolaire supprimée"
  end

  def export_bilan_csv
    school_period = SchoolPeriod.find(params[:id])
    camps = school_period.camps.order(:starts_at)
    activities = school_period.activities.order(:camp_id)
    authorize([:managers, school_period])

    respond_to do |format|
      format.csv do
        headers['Content-Type'] = 'text/csv; charset=UTF-8'

        if params[:export_type] == "all"
          csv_files = []

          # Export by activities
          csv_data = CSV.generate(col_sep: ';', encoding: 'UTF-8') do |csv|
            csv << ["Semaine", "Activite", "Total Eleves", "Garçons", "Filles", "Age moyen", "Taux absenteisme %"]
            activities.each do |activity|
              csv << [activity.camp.name, activity.name, activity.students_count, activity.number_of_students("Garçon"), activity.number_of_students("Fille"), activity.age_of_students, activity.absenteeism_rate]
            end
          end
          csv_files << { data: csv_data, filename: "bilan_par_activite_#{school_period.academy.name}_#{school_period.name}_#{school_period.year}.csv" }

          # Export by semaine
          csv_data = CSV.generate(col_sep: ';', encoding: 'UTF-8') do |csv|
            csv << ["Semaine", "Total Eleves", "Garçons", "Filles", "Age moyen"]
            camps.each do |camp|
              csv << [camp.name, camp.students_count, camp.number_of_students("Garçon"), camp.number_of_students("Fille"), camp.age_of_students]
            end
          end
          csv_files << { data: csv_data, filename: "bilan_par_semaine_#{school_period.academy.name}_#{school_period.name}_#{school_period.year}.csv" }

          # Export by age
          csv_data = CSV.generate(col_sep: ';', encoding: 'UTF-8') do |csv|
            csv << ["Age", "Semaine1", "Semaine2"]
            school_period.participant_ages.each do |age|
              csv << [age, camps.first.number_of_students_by_age(age), camps.second.number_of_students_by_age(age)]
            end
          end
          csv_files << { data: csv_data, filename: "bilan_par_age_#{school_period.academy.name}_#{school_period.name}_#{school_period.year}.csv" }

          # Export by department
          csv_data = CSV.generate(col_sep: ';', encoding: 'UTF-8') do |csv|
            csv << ["Departement", "Semaine1", "Semaine2"]
            school_period.participant_departments.each do |department|
              csv << [department, camps.first.number_of_students_by_dpt(department), camps.second.number_of_students_by_dpt(department)]
            end
          end
          csv_files << { data: csv_data, filename: "bilan_par_departement_#{school_period.academy.name}_#{school_period.name}_#{school_period.year}.csv" }

          # Generate and send a zip file containing all CSV files
          zip_data = generate_zip_file(csv_files)
          send_data(zip_data, filename: "bilan_export.zip")
        else
          # Single export type
          headers['Content-Disposition'] = "attachment; filename=\"bilan.csv\""

          csv_data = CSV.generate(col_sep: ';', encoding: 'UTF-8') do |csv|
            if params[:export_type] == "activities"
              csv << ["Semaine", "Activite", "Total Eleves", "Garçons", "Filles", "Age moyen", "Taux absenteisme %"]
              activities.each do |activity|
                csv << [activity.camp.name, activity.name, activity.students_count, activity.number_of_students("Garçon"), activity.number_of_students("Fille"), activity.age_of_students, activity.absenteeism_rate]
              end
            elsif params[:export_type] == "semaine"
              csv << ["Semaine", "Total Eleves", "Garçons", "Filles", "Age moyen"]
              camps.each do |camp|
                csv << [camp.name, camp.students_count, camp.number_of_students("Garçon"), camp.number_of_students("Fille"), camp.age_of_students]
              end
            elsif params[:export_type] == "age"
              csv << ["Age", "Semaine1", "Semaine2"]
              school_period.participant_ages.each do |age|
                csv << [age, camps.first.number_of_students_by_age(age), camps.second.number_of_students_by_age(age)]
              end
            elsif params[:export_type] == "department"
              csv << ["Departement", "Semaine1", "Semaine2"]
              school_period.participant_departments.each do |department|
                csv << [department, camps.first.number_of_students_by_dpt(department), camps.second.number_of_students_by_dpt(department)]
              end
            end
          end

          send_data(csv_data, filename: "bilan.csv")
        end
      end
    end
  end

  private

  def generate_zip_file(csv_files)
    require 'zip'

    temp_file = Tempfile.new('bilan_export')
    Zip::OutputStream.open(temp_file.path) do |zip|
      csv_files.each do |csv_file|
        zip.put_next_entry(csv_file[:filename])
        zip.write(csv_file[:data])
      end
    end

    File.read(temp_file.path)
  end

  def school_period_params
    params.require(:school_period).permit(:name, :year, :paid, :price)
  end

end
