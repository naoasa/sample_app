require "test_helper"

class UsersSignup < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear
  end
end

class UsersSignupTest < UsersSignup

  test "invalid signup information" do
    get signup_path
    assert_no_difference 'User.count' do
      post users_path, params: { user: { name: "",
                                         email: "user@invalid",
                                         password: "foo",
                                         password_confirmation: "bar" } }
    end
    assert_response :unprocessable_entity
    assert_template 'users/new' # /users/new.html.erbが描画されているか
    assert_select 'div#error_explanation' # CSSのエラー表示部のid
    assert_select 'div.field_with_errors' # CSSのエラー表示部のclass
  end

  test "valid signup information with account activation" do
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name: "Example User",
                                         email: "user@example.com",
                                         password:              "password",
                                         password_confirmation: "password" } }
    end
    assert_equal 1, ActionMailer::Base.deliveries.size # 配信されたメッセージがきっかり1件かどうかを確認
  end
end


class AccountActivationTest < UsersSignup

  def setup
    super # 基底クラスのsetupを呼び出し
    post users_path, params: { user: { name:  "Example User",
                                       email: "user@example.com",
                                       password:              "password",
                                       password_confirmation: "password" } }
    @user = assigns(:user) # @usersにアクセスできるようになる
  end

  test "should not be activated" do
    assert_not @user.activated? # 有効化済みではないことを確認
  end

  test "should not be able to log in before account activation" do
    log_in_as(@user) # @userとしてログイン
    assert_not is_logged_in? # ログイン済みにはならないことを確認
  end

  test "should not be able to log in with invalid activation token" do # 無効な有効化トークンではログインできない
    get edit_account_activation_path("invalid token", email: @user.email) # 無効な有効化トークンを渡す
    assert_not is_logged_in? # ログイン済みではないことを確認
  end

  test "should not be able to log in with invalid email" do # 無効なメールアドレスではログインできない
    get edit_account_activation_path(@user.activation_token, email: 'wrong') # 有効な有効化トークンと、無効なメアドを渡す
    assert_not is_logged_in? # ログイン済みではないことを確認
  end

  test "should log in successfully with valid activation token and email" do # 有効な有効化トークンとメアドで、ログインできる
    get edit_account_activation_path(@user.activation_token, email: @user.email) # 有効な有効化トークンとメアドを渡す
    assert @user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
  end
end