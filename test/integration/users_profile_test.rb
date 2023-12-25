require "test_helper"

class UsersProfileTest < ActionDispatch::IntegrationTest
  include ApplicationHelper # ヘルパーの読み込み

  def setup
    @user = users(:michael)
  end

  test "profile display" do
    get user_path(@user)
    assert_template 'users/show'
    assert_select 'title', full_title(@user.name) # ヘルパー読み込みによってfull_titleヘルパーを利用できている
    assert_select 'h1', text: @user.name # h1タグにユーザー名がある
    assert_select 'h1>img.gravatar'
    assert_match @user.microposts.count.to_s, response.body
    assert_select 'div.pagination', count: 1
    @user.microposts.paginate(page: 1).each do |micropost|
      assert_match micropost.content, response.body
    end
  end

  test "should display stats on profile" do
    get user_path(@user)
    assert_select "div.stats" # statsクラスのdivタグがある
    assert_select "a[href=?]", following_user_path(@user) # フォロイー一覧のリンクがある
    assert_select "a[href=?]", followers_user_path(@user) # フォロワー一覧のリンクがある
    assert_match @user.active_relationships.count.to_s, response.body # フォロー数が表示されている
    assert_match @user.passive_relationships.count.to_s, response.body # フォロワー数が表示されている
  end
end
