class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]

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
  end

  private

    def micropost_params # Strong Parameters
      params.require(:micropost).permit(:content)
    end
end
