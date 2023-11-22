require "test_helper"

class UsersIndexTest < ActionDispatch::IntegrationTest

  def setup
    # @user = users(:michael)
    @admin     = users(:michael) # 管理者
    @non_admin = users(:archer) # 管理者ではないユーザー
  end

  test "index as admin including pagination and delete links" do # 管理者はページネーションと削除リンクが見られる
    log_in_as(@admin) # michael(管理者)としてログイン
    get users_path # '/users'へアクセス(ユーザー一覧にGETリクエスト)
    assert_template 'users/index' # indexビューが表示
    assert_select 'div.pagination', count: 2 # paginationクラスを持つdivタグが2個あることを確認
    User.paginate(page: 1).each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
    end
    first_page_of_users = User.paginate(page: 1) # 1ページ目のユーザーたちを変数へ格納
    first_page_of_users.each do |user| # 1ページ目のユーザーたちでeach文を回す
      assert_select 'a[href=?]', user_path(user), text: user.name # ユーザー名のaタグ(ユーザーページに飛ぶ)があることを確認
      unless user == @admin # リンク対象ユーザーが管理者ではない場合
        assert_select 'a[href=?]', user_path(user), text: 'delete' # [delete]リンクが表示されることを確認
      end
    end
    assert_difference 'User.count', -1 do # ユーザー数が'1'減ることを確認
      delete user_path(@non_admin) # ユーザー(not管理者)URLに対してDELETEリクエスト
      assert_response :see_other
      assert_redirected_to users_url # ユーザー一覧URLにリダイレクト
    end
  end

  test "index as non-admin" do # ユーザー(not管理者)がユーザー一覧を見ようとする
    log_in_as(@non_admin) # 一般ユーザーとしてログイン
    get users_path # ユーザー一覧ページにGETリクエスト
    assert_select 'a', text: 'delete', count: 0 # [delete]リンクが非表示であることを確認
  end
end
