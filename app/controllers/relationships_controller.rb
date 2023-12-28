class RelationshipsController < ApplicationController
  before_action :logged_in_user # アクションにはログイン済みであることが必須

  def create
    @user = User.find(params[:followed_id]) # _follow.html.erbより
    current_user.follow(@user) # followメソッドを実行
    respond_to do |format|
      format.html { redirect_to @user }
      format.turbo_stream
    end
  end

  def destroy
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow(@user) # unfollowメソッドを実行
    respond_to do |format|
      format.html { redirect_to @user, status: :see_other }
      format.turbo_stream
    end
  end
end
