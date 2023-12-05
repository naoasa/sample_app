class PasswordResetsController < ApplicationController
  before_action :get_user,         only: [:edit, :update]
  before_action :valid_user,       only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update] # 有効期限切れを確認

  def new
  end

  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase) # 入力されたメアドからユーザーを見つけて代入
    if @user # ユーザーが見つかれば
      @user.create_reset_digest # メソッドを実行
      @user.send_password_reset_email # メソッドを実行
      flash[:info] = "Email sent with password reset instructions" # フラッシュメッセージ
      redirect_to root_url # ルートURLにリダイレクト
    else # メアドをもとにユーザーが見つからない場合
      flash.now[:danger] = "Email address not found"
      render 'new', status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if params[:user][:password].empty? # 新しいパスワードが空文字の場合 (3)への対応
      @user.errors.add(:password, "can't be empty") # エラーメッセージを追加
      render 'edit', status: :unprocessable_entity
    elsif @user.update(user_params) # 新しいパスワードが正しい場合の更新処理 (4)への対応
      forget(@user) # 演習のコード(これでセッションハイジャックが防止できているはず)
      reset_session # セッションをリセット
      log_in @user # @userとしてログイン
      flash[:success] = "Password has been reset." # 成功メッセージ
      redirect_to @user # リダイレクト
    else
      render 'edit', status: :unprocessable_entity # 無効なパスワードであれば失敗させる (2)への対応
    end
  end


  private

    def user_params
      params.require(:user).permit(:password, :password_confirmation)
    end

    # beforeフィルタ

    def get_user
      @user = User.find_by(email: params[:email])
    end

    # 有効なユーザーかどうか確認する
    def valid_user
      unless (@user && @user.activated? && # ユーザーが存在し、ユーザーが有効化されていて、
              @user.authenticated?(:reset, params[:id])) # 渡されたトークンがダイジェスト一致しているか
        redirect_to root_url
      end
    end

    # トークンが期限切れかどうか確認する
    def check_expiration
      if @user.password_reset_expired? # 期限切れであるか否か
        flash[:danger] = "Password reset has expired."
        redirect_to new_password_reset_url
      end
    end
end
