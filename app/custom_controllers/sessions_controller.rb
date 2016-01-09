class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.where(email: params[:email]).first
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      flash[:notice] = "Vous êtes authentifié"
      redirect_to root_path
    else
      flash[:alert] = "Identifiants incorrects"
      redirect_to new_session_path
    end
  end

  def destroy
    session[:user_id] = nil
    flash[:notice] = "Vous êtes déconnecté"
    redirect_to root_path
  end
end