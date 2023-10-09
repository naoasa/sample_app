class UsersController < ApplicationController

  def show
    @user = User.find(params[:id]) # 例: User.find(1)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      # redirect_to @userと表記しても良い
      redirect_to user_url(@user)
    else
      render 'new', status: :unprocessable_entity
    end
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end
end
