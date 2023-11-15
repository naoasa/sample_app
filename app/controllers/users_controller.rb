class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update] # ログイン後のユーザーに許されたアクション
  before_action :correct_user,   only: [:edit, :update]

  def index
    @users = User.all # 全ユーザーを@usersへ格納(あとでリファクタリングする)
  end

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
  end

  def update # ユーザー情報の更新
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

    # beforeフィルタ

    # ログイン済みユーザーかどうか確認
    def logged_in_user
      unless logged_in?
        store_location # アクセスしようとしたURLを保存するヘルパーメソッド
        flash[:danger] = "Please log in."
        redirect_to login_url, status: :see_other
      end
    end

    # 正しいユーザーかどうか確認
    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_url, status: :see_other) unless current_user?(@user)
    end
end
