require "test_helper"

# 全ユーザーのクラス
class UsersIndex < ActionDispatch::IntegrationTest

  def setup
    # @user = users(:michael)
    @admin     = users(:michael) # 管理者
    @non_admin = users(:archer) # 管理者ではないユーザー
  end
end

# 管理者のクラス
class UsersIndexAdmin < UsersIndex

  def setup
    super
    log_in_as(@admin)
    get users_path
  end
end

# 管理者としてユーザー一覧を見る
class UsersIndexAdminTest < UsersIndexAdmin

  test "should render the index page" do
    assert_template 'users/index'
  end

  test "should paginate users" do
    assert_select 'div.pagination'
  end

  test "should have delete links" do
    first_page_of_users = User.where(activated: true).paginate(page: 1)
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      unless user == @admin # リンク対象ユーザーが管理者でない限り
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end
  end

  test "should be able to delete non-admin user" do
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
    assert_response :see_other
    assert_redirected_to users_url
  end

  test "should display only activated users" do
    # ページにいる最初のユーザーを無効化する。
    # 無効なユーザーを作成するだけでは、
    # Railsで最初のページに表示される保証がないので不十分 ... toggleメソッドはboolean値を反転させる。先頭に「!」付きならDBへ反映
    User.paginate(page: 1).first.toggle!(:activated)
    # /usersを再度取得して、無効化済みのユーザーが表示されていないことを確かめる
    get users_path
    # 表示されているすべてのユーザーが有効化済みであることを確かめる
    assigns(:users).each do |user|
      assert user.activated?
    end
  end

  # test "index as admin including pagination and delete links" do # 管理者はページネーションと削除リンクが見られる
  #   assert_template 'users/index' # indexビューが表示
  #   assert_select 'div.pagination', count: 2 # paginationクラスを持つdivタグが2個あることを確認
  #   # User.paginate(page: 1).each do |user|
  #   #   assert_select 'a[href=?]', user_path(user), text: user.name
  #   # end
  #   first_page_of_users = User.paginate(page: 1) # 1ページ目のユーザーたちを変数へ格納
  #   first_page_of_users.each do |user| # 1ページ目のユーザーたちでeach文を回す
  #     assert_select 'a[href=?]', user_path(user), text: user.name # ユーザー名のaタグ(ユーザーページに飛ぶ)があることを確認
  #     unless user == @admin # リンク対象ユーザーが管理者ではない場合
  #       assert_select 'a[href=?]', user_path(user), text: 'delete' # [delete]リンクが表示されることを確認
  #     end
  #   end
  #   assert_difference 'User.count', -1 do # ユーザー数が'1'減ることを確認
  #     delete user_path(@non_admin) # ユーザー(not管理者)URLに対してDELETEリクエスト
  #     assert_response :see_other
  #     assert_redirected_to users_url # ユーザー一覧URLにリダイレクト
  #   end
  # end

  test "index as non-admin" do # ユーザー(not管理者)がユーザー一覧を見ようとする
    log_in_as(@non_admin) # 一般ユーザーとしてログイン
    get users_path # ユーザー一覧ページにGETリクエスト
    assert_select 'a', text: 'delete', count: 0 # [delete]リンクが非表示であることを確認
  end
end

class UsersNonAdminIndexTest < UsersIndex

  test "should not have delete links as non-admin" do
    log_in_as(@non_admin) # 一般ユーザーとしてログイン
    get users_path
    assert_select 'a', text: 'delete', count: 0 # 'delete'の文字のaタグは0個のハズだよね？
  end
end