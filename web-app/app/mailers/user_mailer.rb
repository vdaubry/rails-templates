class UserMailer < ActionMailer::Base
  default from: "noreply@1job1passion.com"
  
  def send_password(user, reset_token)
    @user = user
    @reset_token = reset_token
    mail(to: @user.email, subject: "Mot de passe oublié ?")
  end
end
