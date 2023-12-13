class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]
  before_action :correct_user,   only: :destroy

  def create
    @micropost = current_user.microposts.build(micropost_params)
    if @micropost.save # ポストが保存されたら
      flash[:success] = "Micropost created!"
      redirect_to root_url
    else # 投稿失敗時の分岐
      @feed_items = current_user.feed.paginate(page: params[:page])
      render 'static_pages/home', status: :unprocessable_entity
    end
  end

  def destroy
    @micropost.destroy
    flash[:success] = "Micropost deleted"
    # if request.referrer.nil?
    #   redirect_to root_url, status: :see_other
    # else
    #   redirect_to request.referrer, status: :see_other
    # end
    redirect_back_or_to(root_url, status: :see_other)
  end

  private

    def micropost_params # Strong Parameters
      params.require(:micropost).permit(:content)
    end

    def correct_user
      @micropost = current_user.microposts.find_by(id: params[:id])
      redirect_to root_url, status: :see_other if @micropost.nil? # 別のユーザーがポストの削除を試した場合はnilが返される
    end
end
