require "test_helper"

class UsersLogin < ActionDispatch::IntegrationTest # UsersLoginを定義

  def setup
    @user = users(:michael)
  end
end

class InvalidPasswordTest < UsersLogin # 誤りパスワードテストのクラス(UsersLoginを継承)

  test "login path" do
    get login_path # ログイン画面のGETリクエスト
    assert_template 'sessions/new' # ログイン画面のビューを確認
  end

  test "login with valid email/invalid password" do # 正しいメアド/誤りパスワード
    post login_path, params: { session: { email:    @user.email,
                                          password: "invalid"} }
    assert_not is_logged_in? # ログイン状態ではないことを確認
    assert_template 'sessions/new' # ログイン画面のビューを確認
    assert_not flash.empty? # フラッシュメッセージが空ではないことを確認
    get root_path # ルートURLへ移動
    assert flash.empty? # フラッシュメッセージが空であることを確認
  end
end

class ValidLogin < UsersLogin # 正しいログインのクラス(UsersLoginを継承)

  def setup
    super # UsersLoginクラスのメソッドを呼び出す
    post login_path, params: { session: { email:    @user.email,
                                          password: 'password'} } # 正しいログイン情報をPOST
  end
end

class ValidLoginTest < ValidLogin # 正しいログインテストのクラス(ValidLoginを継承)

  test "valid login" do # 正しいログインのテスト
    assert is_logged_in? # ログイン状態であることを確認
    assert_redirected_to @user # ユーザー画面へのリダイレクトを確認
  end

  test "redirect after login" do
    follow_redirect! # リダイレクト先に移動
    assert_template 'users/show' # ユーザー画面のビューを確認
    assert_select "a[href=?]", login_path, count: 0 # ログインリンクが見えない
    assert_select "a[href=?]", logout_path # ログアウトリンクが見える
    assert_select "a[href=?]", user_path(@user) # ユーザーリンクが見える
  end
end

class Logout < ValidLogin # ログアウトクラスを定義(ValidLoginを継承)

  def setup
    super # ValidLoginクラスのメソッドを呼び出す
    delete logout_path # ログアウトURLへDELETEリクエスト
  end
end

class LogoutTest < Logout # ログアウトのテスト(Logoutを継承)

  test "successful logout" do # ログアウトの成功自体をテスト
    assert_not is_logged_in? # ログイン状態ではないことを確認
    assert_response :see_other # 303 See Otherを確認
    assert_redirected_to root_url # ルートURLへのリダイレクトを確認
  end

  test "redirect after logout" do # ログアウト後のリダイレクトのテスト
    follow_redirect! # リダイレクト先に移動(ここからはログアウト後の世界)
    assert_select "a[href=?]", login_path # ログインリンクが見える
    assert_select "a[href=?]", logout_path,      count: 0 # ログアウトリンクが見えない
    assert_select "a[href=?]", user_path(@user), count: 0 # ユーザーリンクが見えない
  end
end
