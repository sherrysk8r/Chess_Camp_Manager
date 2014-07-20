class SessionsController < ApplicationController
  # def new
  # end

  def create
    user = User.find_by_username(params[:username])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect_to home_path, alert: "You are logged into the chess camp system."
    else
      redirect_to home_path, alert: "Username or password is invalid"
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to home_path, alert: "Logged out!"
  end
end