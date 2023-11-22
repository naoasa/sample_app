require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest

  def setup
    @user       = users(:michael)
    @other_user = users(:archer)
  end

  test "should get new" do
    get signup_path
    assert_response :success
  end

  test "should redirect index when not logged in" do # 未ログインのユーザーは一覧ページが見られずログイン画面へリダイレクト
    get users_path # ユーザー一覧にGETリクエスト
    assert_redirected_to login_url # ログイン画面へリダイレクト
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

  test "should not allow the admin attribute to be edited via the web" do # admin属性はWeb経由で編集できないようにすべき
    log_in_as(@other_user) # @other_userとしてログイン
    assert_not @other_user.admin? # @other_userが管理者ではないことを確認
    patch user_path(@other_user), params: {
                                    user: { password: "password",
                                            password_confirmation: "password",
                                            admin: true } } # Web経由でadmin属性の変更を試みる
    assert_not @other_user.reload.admin? # @other_userのadmin属性がtrueではない(変わっていない)ことを確認
  end

  test "should redirect destroy when not logged in" do # 未ログインのユーザーはdestroy実行時リダイレクトされる
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_response :see_other
    assert_redirected_to login_url
  end

  test "should redirect destroy when logged in as a non-admin" do # 管理者でないユーザーはdestroy実行時リダイレクトされる
    log_in_as(@other_user)
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end
    assert_response :see_other
    assert_redirected_to root_url
  end
end
