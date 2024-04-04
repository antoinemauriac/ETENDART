class Managers::EnrollmentsController < ApplicationController

  def create
    student = Student.find(params[:student_id])
    authorize([:managers, student], policy_class: Managers::EnrollmentPolicy)

    academy = Academy.find(params[:academy])
    student.academies << academy unless student.academies.include?(academy)

    school_period = SchoolPeriod.find(params[:school_period])
    student.school_periods << school_period unless student.school_periods.include?(school_period)

    if school_period.tshirt == true
      school_period_enrollments = student.school_period_enrollments
                                         .joins(:school_period)
                                         .where(school_periods: { academy_id: academy.id })

      school_period_enrollment = student.school_period_enrollments.find_by(school_period: school_period)
      if school_period_enrollments.any? { |school_period_enrollment| school_period_enrollment.tshirt_delivered == true }
        school_period_enrollment.update(tshirt_delivered: true)
      end
    end

    camp = Camp.find(params[:camp])
    student.camps << camp unless student.camps.include?(camp)

    start_year = camp.starts_at.month >= 4 ? camp.starts_at.year : camp.starts_at.year - 1
    membership = student.memberships.find_by(start_year: start_year)
    if membership.nil?
      student.memberships.create(amount: 15, start_year: start_year)
    end

    image_consent = params[:image_consent]
    camp_enrollment = student.camp_enrollments.find_by(camp: camp)
    camp_enrollment.update(image_consent: image_consent)

    activity = Activity.find(params[:activity])
    if student.activities.include?(activity)
      redirect_to managers_student_path(student)
      flash[:alert] = "L'élève est déjà inscrit à cette activité"
    else
      student.courses << activity.next_courses
      student.activities << activity
      redirect_to managers_student_path(student)
      flash[:notice] = "Inscription validée"
    end
  end

  def update_school_periods
    academy = Academy.find(params[:academy_id])
    authorize([:managers, academy], policy_class: Managers::EnrollmentPolicy)
    school_periods = academy.school_periods.select(:id, :name, :year).select { |school_period| school_period.ends_at >= Date.today }
    render json: school_periods.as_json(methods: :full_name)
  end

  def update_camps
    school_period = SchoolPeriod.find(params[:school_period_id])
    authorize([:managers, school_period], policy_class: Managers::EnrollmentPolicy)
    camps = school_period.camps
    render json: camps.select(:id, :name).where('ends_at >= ?', Date.today).order(:starts_at)
  end

  def update_activities
    camp = Camp.find(params[:camp_id])
    authorize([:managers, camp], policy_class: Managers::EnrollmentPolicy)
    activities = camp.activities
    render json: activities.select(:id, :name).order(:name)
  end

end
