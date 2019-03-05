class RecoverPasswordsController < ActionController::Base
  layout "application"

  before_action :set_recovery_token
  before_action :set_current_user
  before_action :verify_token

  def new
  end

  def create
    if @current_user.update(
      password: params[:password],
      password_confirmation: params[:password_confirmation]
    )
      return render plain: "Votre mot de passe a bien été mis à jour"
    else
      @errors = @current_user.errors
      render :new
    end
  end

  private
  def set_current_user
    @current_user = User.find_by(id: user_id_from_reset_token)
  end

  def user_id_from_reset_token
    $redis.get("1job1passion:users:#{@recovery_token}:reset_password_token")
  end

  def verify_token
    return render plain: "Link invalid, please check your reset password email link" unless @current_user
  end

  def set_recovery_token
    @recovery_token = params[:recovery_token]
  end
end
