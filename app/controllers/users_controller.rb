class UsersController < ApplicationController

  def show
    @user = User.find(params[:id]) # 例: User.find(1)
  end

  def new
  end
end
