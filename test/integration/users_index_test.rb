require "test_helper"

class UsersIndexTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  test "index including pagination" do
    log_in_as(@user) # michaelとしてログイン
    get users_path # '/users'へアクセス
    assert_template 'users/index' # indexビューが表示
    assert_select 'div.pagination' # paginationクラスを持つdivタグを確認
    User.paginate(page: 1).each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
    end
  end
end
