class UsersController < ApplicationController

  def index
    authorize User
    @users = User.all
  end

  def new
    @user = authorize User.new
  end

  def create
    @user = authorize User.new(user_params)
    @user.save
    if @user.errors.any?
      render :new
    else
      redirect_to @user
    end
  end

  def show
    @user = authorize User.find(params[:id])
  end

  def edit
    @user = authorize User.find(params[:id])
  end

  def update
    @user = authorize User.find(params[:id])
    @user.update(user_params)
    if @user.errors.any?
      render :edit
    else
      redirect_to @user
    end
  end

  def destroy
    @user = authorize User.find(params[:id])
  end

private

  def user_params
    params.require(:user).permit!
  end

end
