class UsersController < ApplicationController
  authorize_resource
  
  def new
    @user = User.new
  end

  def edit
    @user = @current_user
  end

  def create
    @user = User.new(user_params)
    if @user.save
      session[:user_id] = @user.id
      redirect_to home_path
    else
      render action: "new"
    end
  end

  def update
    @user = @current_user
    if @user.update_attributes(user_params)
      redirect_to(@user, notice: 'User was successfully updated.')
    else
      render action: "edit"
    end
  end

  private
  def user_params
    params.require(:user).permit(:username, :password, :password_confirmation, :active, :instructor_id)
  end
end
