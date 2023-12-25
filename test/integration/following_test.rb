require "test_helper"

class Following < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
    log_in_as(@user) # michaelとしてログイン
  end
end

class FollowPagesTest < Following

  test "following page" do
    get following_user_path(@user) # michaelのフォロイー一覧にGETリクエスト
    assert_response :success
    assert_not @user.following.empty? # フォロイーは空ではない
    assert_match @user.following.count.to_s, response.body
    @user.following.each do |user|
      assert_select "a[href=?]", user_path(user) # ユーザー1人ごとにプロフィールへのリンクがある
    end
  end

  test "followers page" do
    get followers_user_path(@user) # michaelのフォロワー一覧にGETリクエスト
    assert_response :success
    assert_not @user.followers.empty? # フォロワーは空ではない
    assert_match @user.followers.count.to_s, response.body
    @user.followers.each do |user|
      assert_select "a[href=?]", user_path(user) # ユーザー1人ごとにプロフィールへのリンクがある
    end
  end
end