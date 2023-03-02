class Managers::EnrollmentsController < ApplicationController

  def create
    @student = Student.find(params[:student_id])
    authorize([:managers, @student], policy_class: Managers::EnrollmentPolicy)

    school_period = SchoolPeriod.find(params[:school_period])
    @student.school_periods << school_period unless @student.school_periods.include?(school_period)

    camp = Camp.find(params[:camp])
    @student.camps << camp unless @student.camps.include?(camp)


    activity = Activity.find(params[:activity])
    if @student.activities.include?(activity)
      redirect_to managers_student_path(@student)
      flash[:alert] = "L'élève est déjà inscrit à cette activité"
    else
      @student.courses << activity.courses
      @student.activities << activity
      redirect_to managers_student_path(@student)
      flash[:notice] = "Inscription validée"
    end
  end

  def update_school_periods
    academy = Academy.find(params[:academy_id])
    authorize([:managers, academy], policy_class: Managers::EnrollmentPolicy)
    school_periods = academy.school_periods
    render json: school_periods.select(:id, :name)
  end

  def update_camps
    school_period = SchoolPeriod.find(params[:school_period_id])
    authorize([:managers, school_period], policy_class: Managers::EnrollmentPolicy)
    camps = school_period.camps
    render json: camps.select(:id, :name)
  end

  def update_activities
    camp = Camp.find(params[:camp_id])
    authorize([:managers, camp], policy_class: Managers::EnrollmentPolicy)
    activities = camp.activities
    render json: activities.select(:id, :name)
  end

end
