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
      reset_session
      log_in @user
      flash[:success] = "Welcome to the Sample App!"
      redirect_to @user
    else
      render 'new', status: :unprocessable_entity
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update # ユーザー情報の更新
    @user = User.find(params[:id])
    if @user.update(user_params) # 更新に成功した場合
      flash[:success] = "Profile updated" # 更新成功を示すフラッシュメッセージ
      redirect_to @user # ユーザーページに遷移
    else
      render 'edit', status: :unprocessable_entity
    end
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end
end
