class AccountActivationsController < ApplicationController
  # ユーザーアカウントを有効化するためのコントローラー

  def edit
    user = User.find_by(email: params[:email]) # メアドをもとにユーザーを探して格納
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      user.activate # アカウントを有効にするメソッド(Userモデルに定義)
      log_in user
      flash[:success] = "Account activated!"
      redirect_to user
    else
      flash[:danger] = "Invalid activation link"
      redirect_to root_url
    end
  end
end
