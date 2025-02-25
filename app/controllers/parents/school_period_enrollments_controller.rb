class Parents::SchoolPeriodEnrollmentsController < ApplicationController
  def new
    @school_period_enrollment = SchoolPeriodEnrollment.new
    @school_period = SchoolPeriod.find(params[:school_period_id])
    @academy = Academy.find(params[:academy_id])
    @students = current_user.children
    @school_period.camps.each do |camp|
      @school_period_enrollment.camp_enrollments.build(camp: camp)
    end
    authorize([:parents, @school_period_enrollment])
  end

  def create
    @school_period_enrollment = SchoolPeriodEnrollment.new(school_period_enrollment_params)
    @school_period = SchoolPeriod.find(params[:school_period_id])
    @academy = Academy.find(params[:academy_id])
    @school_period_enrollment.student = current_user.student
    authorize([:parents, @school_period_enrollment])
    if @school_period_enrollment.save
      redirect_to parents_academy_path(@academy)
    else
      render :new
    end
  end

end
