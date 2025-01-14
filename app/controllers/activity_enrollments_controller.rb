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

    if @activity_enrollment.camp.camp_enrollment
      redirect_to academy_school_period_activity_path(@activity_enrollment.activity.academy, @activity_enrollment.activity.school_period, @activity_enrollment.activity), alert: 'Vous ne pouvez pas supprimer une inscription payée'
      return
    end

    if @activity_enrollment.activity.past?
      redirect_to academy_school_period_activity_path(@activity_enrollment.activity.academy, @activity_enrollment.activity.school_period, @activity_enrollment.activity), alert: 'Vous ne pouvez pas supprimer une inscription à une activité passée'
      return
    end

    camp_enrollment = @activity_enrollment.camp_enrollment
    other_activities = camp_enrollment.activity_enrollments.where.not(id: @activity_enrollment.id)

    if other_activities.exists?
      @activity_enrollment.destroy
    else
      cart_item = camp_enrollment.cart_item
      camp_enrollment.destroy
      cart_item.destroy unless cart_item.paid?
    end

    redirect_to academy_school_period_activity_path(@activity_enrollment.activity.academy, @activity_enrollment.activity.school_period, @activity_enrollment.activity), notice: 'Inscription supprimée'
  end

  private

  def activity_enrollment_params
    params.require(:activity_enrollment).permit(:student_id, :activity_id)
  end
end
