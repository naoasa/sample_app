require "test_helper"

class MicropostTest < ActiveSupport::TestCase

  def setup
    @user = users(:michael)
    # このコードは慣習的に正しくない
    @micropost = Micropost.new(content: "Lorem ipsum", user_id: @user.id)
  end

  test "should be valid" do
    assert @micropost.valid? # ポストは有効であるか
  end

  test "user id should be present" do
    @micropost.user_id = nil # ポストと関連付けられたユーザーのidをnilにする
    assert_not @micropost.valid? # ポストが有効ではないことを確認
  end

  test "content should be present" do # contentは存在する
    @micropost.content = "   "
    assert_not @micropost.valid? # ポストが有効ではないことを確認
  end

  test "content should be at most 140 characters" do # せいぜい140文字であることを確認
    @micropost.content = "a" * 141 # aが141文字のポスト
    assert_not @micropost.valid? # ポストが有効ではないことを確認
  end
end
