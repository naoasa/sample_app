require "test_helper"

class SiteLayoutTest < ActionDispatch::IntegrationTest

  test "layout links" do
    get root_path
    assert_template 'static_pages/home'
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
    assert_select "a[href=?]", login_path
    get contact_path # '/contact'へアクセス
    assert_select "title", full_title("Contact") # <title>full_title("Contact")</title>
    get signup_path # '/signup'へアクセス
    assert_select "title", full_title("Sign up") #<title>full_title("Sign up")</title>
    get login_path # '/login'へアクセス
    assert_select "title", full_title("Log in") #<title>full_title("Log in")</title>
  end

  def setup
    @user = users(:michael)
  end

  test "layout links when logged in" do
    log_in_as(@user) # ヘルパーを用いてログイン
    get root_path
    assert_template 'static_pages/home'
    assert_select "a[href=?]", users_path # ユーザー一覧へのリンク
    assert_select "a[href=?]", user_path(@user) # プロフィールへのリンク
    assert_select "a[href=?]", edit_user_path(@user) # プロフィール編集へのリンク
    assert_select "a[href=?]", logout_path # ログアウトへのリンク
    get users_path # "/users"へアクセス
    assert_select "title", full_title("All users")
    get user_path(@user) # "/users/:id"へアクセス
    assert_select "title", full_title("#{@user.name}")
    get edit_user_path(@user) # "/users/:id/edit"へアクセス
    assert_select "title", full_title("Edit user")
  end

  test "should display stats" do
    log_in_as(@user) # michaelとしてログイン
    get root_path # ルートURLへGETリクエスト
    assert_select "div.stats" # statsクラスのdivタグがある
    assert_select "a[href=?]", following_user_path(@user) # フォロイー一覧のリンクがある
    assert_select "a[href=?]", followers_user_path(@user) # フォロワー一覧のリンクがある
    assert_match @user.active_relationships.count.to_s, response.body # フォロー数が表示されている
    assert_match @user.passive_relationships.count.to_s, response.body # フォロワー数が表示されている
  end
end