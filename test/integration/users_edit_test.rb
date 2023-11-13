require "test_helper"

class UsersEditTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  test "unsuccessful edit" do # 編集失敗に対するテスト
    log_in_as(@user) # テスト前にログイン
    get edit_user_path(@user)
    assert_template 'users/edit'
    patch user_path(@user), params: { user: { name: "",
                                              email: "foo@invalid",
                                              password:              "foo",
                                              password_confirmation: "bar" } }
    assert_template 'users/edit'
    assert_select "div.alert", "The form contains 4 errors." # alertクラスのdivタグで、4つのエラー文が出る
  end

  test "successful edit" do # 編集成功に対するテスト
    log_in_as(@user) # テスト前にログイン
    get edit_user_path(@user) # 編集ページへGETリクエスト
    assert_template 'users/edit' # 正しいビューの表示
    name = "Foo Bar" # nameに"Foobar"を代入
    email = "foo@bar.com" # emailに"foo@bar.com"を代入
    patch user_path(@user), params: { user: { name:  name,
                                              email: email,
                                              password:              "",
                                              password_confirmation: "" } }
    assert_not flash.empty? # フラッシュメッセージが空ではない
    assert_redirected_to @user # プロフィール画面へ遷移
    @user.reload # ユーザー情報を再読み込み
    assert_equal name,  @user.name
    assert_equal email, @user.email
  end
end