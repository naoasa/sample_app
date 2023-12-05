require "test_helper"

class PasswordResets < ActionDispatch::IntegrationTest

  def setup
    ActionMailer::Base.deliveries.clear # メーラーをクリアにする
  end
end

class ForgotPasswordFormTest < PasswordResets

  test "password reset path" do
    get new_password_reset_path # /password_resets/newにGETリクエスト
    assert_template 'password_resets/new' # ビューの表示を確認
    assert_select 'input[name=?]', 'password_reset[email]' # inputタグの確認
  end

  test "reset path with invalid email" do # 無効なメアド送信時のテスト
    post password_resets_path, params: { password_reset: { email: "" } } # 空文字をPOSTリクエスト
    assert_response :unprocessable_entity # 4XX番台のステータス
    assert_not flash.empty? # フラッシュメッセージが空ではない
    assert_template 'password_resets/new'
  end
end

class PasswordResetForm < PasswordResets

  def setup
    super # setupを引き継ぐ
    @user = users(:michael) # @userを定義
    post password_resets_path,
         params: { password_reset: { email: @user.email } }
    @reset_user = assigns(:user) # @reset_userを定義
  end
end

class PasswordFormTest < PasswordResetForm

  test "reset with valid email" do # 有効なメアド送信時の挙動
    assert_not_equal @user.reset_digest, @reset_user.reset_digest # @userと@reset_userのリセットダイジェストは違うはず
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty? # フラッシュメッセージは空ではないはず
    assert_redirected_to root_url # ルートURLにリダイレクトするはず
  end

  test "reset with wrong email" do # 無効なメアド送信時の挙動
    get edit_password_reset_path(@reset_user.reset_token, email: "") # メアド送信できていない => GETリクエスト
    assert_redirected_to root_url
  end

  test "reset with inactive user" do # 有効化済みではないユーザーによる送信時の挙動
    @reset_user.toggle!(:activated)
    get edit_password_reset_path(@reset_user.reset_token,
                                 email: @reset_user.email) # 正しいメアド
    assert_redirected_to root_url
  end

  test "reset with right email but wrong token" do # 正しいメアドと違うトークン送信時の挙動
    get edit_password_reset_path('wrong token', email: @reset_user.email)
    assert_redirected_to root_url
  end

  test "reset with right email and right token" do # 正しいメアドと正しいトークン送信時の挙動
    get edit_password_reset_path(@reset_user.reset_token,
                                 email: @reset_user.email)
    assert_template 'password_resets/edit'
    # 下記コードは<input id="email" name="email" type="hidden" value="michael@example.com" />を確認
    assert_select "input[name=email][type=hidden][value=?]", @reset_user.email
  end
end

class PasswordUpdateTest < PasswordResetForm

  test "update with invalid password and confirmation" do # パスワードとパスワード確認が異なるときの挙動
    patch password_reset_path(@reset_user.reset_token),
          params: { email: @reset_user.email,
                    user: { password:              "foobaz123",
                            password_confirmation: "barquux123" } }
    assert_select 'div#error_explanation'
  end

  test "update with empty password" do # パスワード空白時の挙動
    patch password_reset_path(@reset_user.reset_token),
          params: { email: @reset_user.email,
                    user: { password:              "",    # パスワード:    空白
                            password_confirmation: "" } } # パスワード確認: 空白
    assert_select 'div#error_explanation'
  end

  test "update with valid password and confirmation" do # 正しいメアドとメアド確認の組み合わせで、更新するときの挙動
    patch password_reset_path(@reset_user.reset_token),
          params: { email: @reset_user.email,
                    user: { password:              "foobaz123",
                            password_confirmation: "foobaz123" } }
    assert is_logged_in? # ログイン済みであるか
    assert_not flash.empty? # フラッシュメッセージが空ではないことを確認
    assert_redirected_to @reset_user # ユーザー画面にリダイレクト
  end
end