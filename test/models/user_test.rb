require "test_helper"

class UserTest < ActiveSupport::TestCase

  def setup # 各テストが走る直前に実行される
    @user = User.new(name: "Example User", email: "user@example.com")
  end

  test "should be valid" do
    assert @user.valid? # valid?メソッドで有効性を確認
  end

  test "name should be present" do # name属性が存ること
    @user.name = "      "
    assert_not @user.valid?
  end

  test "email should be present" do # email属性が存ること
    @user.email = "      "
    assert_not @user.valid?
  end

  test "name should be too long" do
    @user.name = "a" * 51 # 51文字の文字列を作る
    assert_not @user.valid? # 失敗、つまり有効性がないならtrue
  end

  test "email should be too long" do
    @user.email = "a" * 244 + "@example.com" # 256文字の文字列を作る
    assert_not @user.valid? # 失敗、つまり有効性がないならtrue
  end
end
