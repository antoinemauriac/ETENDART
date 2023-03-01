class Managers::EnrollmentsController < ApplicationController

  def create
    @student = Student.find(params[:student_id])

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


end
