class PasswordResetsController < ApplicationController
  before_action :get_user,   only: [:edit, :update]
  before_action :valid_user, only: [:edit, :update]

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


  private

    def get_user
      @user = User.find_by(email: params[:email])
    end

    # 正しいユーザーかどうか確認する
    def valid_user
      unless (@user && @user.activated? && # ユーザーが存在し、ユーザーが有効化されていて、
              @user.authenticated?(:reset, params[:id])) # 渡されたトークンがダイジェスト一致しているか
        redirect_to root_url
      end
    end
end
