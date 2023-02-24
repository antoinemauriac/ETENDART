class CoachMailer < ApplicationMailer
  def confirm_email(coach)
    @coach = coach
    mail(to: @coach.email, subject: 'Confirmez votre compte de coach')
  end
end
