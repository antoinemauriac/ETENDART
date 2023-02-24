# Preview all emails at http://localhost:3000/rails/mailers/coach_mailer
class CoachMailerPreview < ActionMailer::Preview
  def confirm_email()
    @coach = User.last
    mail(to: @coach.email, subject: 'Confirmez votre compte de coach')
  end
end
