require "test_helper"

class UserTest < ActiveSupport::TestCase

  def setup # 各テストが走る直前に実行される
    @user = User.new(name: "Example User", email: "user@example.com",
                     password: "foobarhoge", password_confirmation: "foobarhoge")
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

  # 有効性のテスト
  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  # 無効性のテスト
  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example. foo@bar_baz.com foo@bar+baz.com foo@bar..com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  # 重複するメールアドレス拒否のテスト
  test "email addresses should be unique" do
    duplicate_user = @user.dup
    @user.save
    assert_not duplicate_user.valid?
  end

  # メールアドレスを小文字で保存するテスト
  test "email addresses should be saved as lowercase" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    @user.email = mixed_case_email # "Foo@ExAMPle.CoM"が代入される
    @user.save # 保存する
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  # パスワードが空ではないテスト
  test "password should be present (nonblank)" do
    @user.password = @user.password_confirmation = " " * 6
    # 偽ならパスする
    assert_not @user.valid?
  end

  # パスワードが8文字以上のテスト
  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 7
    # 偽ならパスする
    assert_not @user.valid?
  end

  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, '') ##
  end

  # ユーザーの削除とともにポストが削除されるかテスト
  test "associated microposts should be destroyed" do
    @user.save # 作成したユーザーを保存
    @user.microposts.create!(content: "Lorem ipsum") # ポストを1つ作成
    assert_difference 'Micropost.count', -1 do # ポスト数が1個減ることを確認
      @user.destroy # ユーザーを削除
    end
  end

  # フォローとフォロー解除のテスト
  test "should follow and unfollow a user" do
    michael = users(:michael)
    archer  = users(:archer)
    assert_not michael.following?(archer) # michaelはarcherをフォローしていないよね？
    michael.follow(archer) # フォロー実行
    assert michael.following?(archer) # michaelはarcherをフォローしているよね？
    michael.unfollow(archer) # フォロー解除実行
    assert_not michael.following?(archer) # michaelはarcherをフォローしていないよね？
    # ユーザーは自分自身をフォローできない
    michael.follow(michael)
    assert_not michael.following?(michael)
  end
end
