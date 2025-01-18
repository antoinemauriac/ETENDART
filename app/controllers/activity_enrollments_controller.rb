class ActivityEnrollmentsController < ApplicationController

  # POST /activity_enrollments

  def create
    @activity_enrollment = ActivityEnrollment.new(activity_enrollment_params)
    authorize(@activity_enrollment)
    # quand je m'inscris a une activité je regarde si je suis déjà inscris au camp de l'activité
    @activity = @activity_enrollment.activity
    @academy = @activity.academy
    @school_period = @activity.school_period
    if @activity_enrollment.save
      redirect_to academy_school_period_activity_path(@academy, @school_period, @activity), notice: 'Inscription réussie'
    else
      redirect_to academy_school_period_activity_path(@activity), alert: 'Erreur lors de l\'inscription'
    end

    # si je suis inscris je m'inscris a l'activité sans payer
    # si je ne suis pas inscris je m'inscris au camp et a l'activité
    # s'inscrire au camp doit créer un cart_item à payer
  end

  # DELETE /activity_enrollments/1
  # je veux supprimer mon inscription a une activité
  # Je ne peux pas supprimer l'inscription de mon enfant si j'ai payé
  # Je ne peux pas supprimer l'inscription de mon enfant si l'activité est passée
  # Vérifier si je suis inscris à une autre activité du même camp
  # Si je suis inscris à une autre activité du même camp je ne supprime pas mon camp_enrollment
  # Si je ne suis pas inscris à une autre activité du même camp, je supprime mon camp_enrollment ET le cart_item associé si je ne l'ai pas payé

  def destroy
    @activity_enrollment = ActivityEnrollment.find(params[:id])
    authorize(@activity_enrollment)
    # est ce que je suis inscris a une autre activité du même camp ?
    if @activity_enrollment.student.is_enrolled_in_other_activities?(@activity_enrollment.activity)
      # Alors je supprime juste l'inscription a l'activité
      @activity_enrollment.destroy
    elsif @activity_enrollment.student.camp_enrollments.find_by(camp: @activity_enrollment.camp).paid
      @activity_enrollment.destroy
    elsif @activity_enrollment.student.camp_enrollments.find_by(camp: @activity_enrollment.camp).camp.starts_at < Date.today
      # Est ce que l'activité est passée ?
      # Alors je ne peux pas supprimer l'inscription a l'activité
      redirect_to academy_school_period_activity_path(@activity_enrollment.activity.academy, @activity_enrollment.activity.school_period, @activity_enrollment.activity), alert: 'Vous ne pouvez pas vous désinscrire d\'une activité passée'
    else
      @activity_enrollment.destroy
      camp_enrollment = @activity_enrollment.student.camp_enrollments.find_by(camp: @activity_enrollment.camp)
      camp_enrollment.destroy
      if cart_item = camp_enrollment.cart_item
        cart_item.destroy
      end
    end
  end

  private

  def activity_enrollment_params
    params.require(:activity_enrollment).permit(:student_id, :activity_id, :payment_method)
  end
end
