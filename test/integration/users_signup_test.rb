require "test_helper"

class UsersSignupTest < ActionDispatch::IntegrationTest

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
end
