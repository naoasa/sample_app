require "test_helper"

class UsersLoginTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  test "login with invalid information" do
    get login_path # ログイン用のパスを開く
    assert_template 'sessions/new' # 新しいセッションのフォームが正しく表示されたことを確認
    post login_path, params: { session: { email: "", password: "" } } # わざと無効なparamsハッシュを使ってセッション用パスにPOSTする
    assert_response :unprocessable_entity # 新しいセッションのフォームが正しいステータスを返すことを確認
    assert_template 'sessions/new' # 新しいセッションのフォームが再度表示されることを確認
    assert_not flash.empty? # フラッシュメッセージが表示されることを確認
    get root_path # 別のページにいったん移動
    assert flash.empty? # 移動先のページでフラッシュメッセージが表示されていないことを確認
  end

  test "login with valid information" do
    post login_path, params: { session: { email:    @user.email,
                                          password: 'password' } }
    assert_redirected_to @user
    follow_redirect!
    assert_template 'users/show'
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)
  end
end
