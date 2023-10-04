class UsersController < ApplicationController

  def show
    @user = User.find(params[:id]) # 例: User.find(1)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user]) # 実装は終わっていないことに注意！
    if @user.save
      # 保存の成功をここで扱う。
    else
      render 'new', status: :unprocessable_entity
    end
  end
end
