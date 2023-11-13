require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user =       users(:michael)
    @other_user = users(:archer)
  end

  test "should get new" do
    get signup_path
    assert_response :success
  end

  test "should redirect edit when not logged in" do
    get edit_user_path(@user) # ユーザー編集URLにGETリクエスト
    assert_not flash.empty? # flashメッセージが空ではない
    assert_redirected_to login_url # ログインURLへリダイレクト
  end

  test "should redirect update when not logged in" do
    # user_path(@user)にPATCHリクエスト
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email } }
    assert_not flash.empty? # flashメッセージが空ではない
    assert_redirected_to login_url # ログインURLへリダイレクト
  end

  test "should redirect edit when logged in as wrong user" do # 違うユーザーで編集ページにアクセスするならリダイレクト
    log_in_as(@other_user) # archerとしてログイン
    get edit_user_path(@user) # michaelの編集URLにGETリクエスト
    assert flash.empty? # flashメッセージが空である
    assert_redirected_to root_url # ルートURLにリダイレクト
  end

  test "should redirect update when logged in as wrong user" do # 違うユーザーで更新しようとしたらリダイレクト
    log_in_as(@other_user) # archerとしてログイン
    patch user_path(@user), params: { user: { name: @user.name,
                                              email: @user.email } } # michaelにPATCHリクエスト
    assert flash.empty? # flashメッセージが空である
    assert_redirected_to root_url # ルートURLにリダイレクト
  end
end
