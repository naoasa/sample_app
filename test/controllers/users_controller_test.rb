require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
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
end
