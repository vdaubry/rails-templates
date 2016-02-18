class MemberMailerPreview < ActionMailer::Preview
  #http://localhost:3000/rails/mailers/user_mailer/welcome
  def welcome
    UserMailer.welcome(User.first)
  end
end