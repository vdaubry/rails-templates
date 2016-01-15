class MemberMailer < ActionMailer::Base
  default from: "contact@domain.com"
  
  def welcome(user)
    @user = user
    mail(to: @user.email, subject: 'Welcome')
  end