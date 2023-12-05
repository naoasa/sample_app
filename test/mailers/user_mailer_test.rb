require "test_helper"

class UserMailerTest < ActionMailer::TestCase

  test "account_activation" do
    user = users(:michael)
    user.activation_token = User.new_token
    mail = UserMailer.account_activation(user)
    assert_equal "Account activation", mail.subject
    assert_equal [user.email], mail.to
    assert_equal ["user@realdomain.com"], mail.from
    assert_match user.name,               mail.body.encoded
    assert_match user.activation_token,   mail.body.encoded
    assert_match CGI.escape(user.email),  mail.body.encoded
  end

  test "password_reset" do # パスワード再設定用メソッドのテスト
    user = users(:michael)
    user.reset_token = User.new_token # reset_tokenを生成
    mail = UserMailer.password_reset(user)
    assert_equal "Password reset", mail.subject # メールの件名
    assert_equal [user.email], mail.to # メールの送信先
    assert_equal ["user@realdomain.com"], mail.from # メールの送信元
    assert_match user.reset_token,          mail.body.encoded
    assert_match CGI.escape(user.email),    mail.body.encoded
  end

end
