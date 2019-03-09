class ResetPasswordJob < ActiveJob::Base
  def perform(user_id)
    user = User.find(user_id)
    reset_password_token = SecureRandom.uuid
    $redis.set("1job1passion:users:#{reset_password_token}:reset_password_token", user_id, {ex: 24*3600})
    UserMailer.send_password(user, reset_password_token).deliver_now unless Rails.env.test?
  end
end
