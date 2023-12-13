require "test_helper"

class MicropostInterface < ActionDispatch::IntegrationTest

  def setup # michaelとしてログイン
    @user = users(:michael)
    log_in_as(@user)
  end
end

class MicropostsInterfaceTest < MicropostInterface

  test "should paginate microposts" do
    get root_path # ルートパスにGETリクエスト
    assert_select 'div.pagination' # ページネーションのdivタグを確認
  end

  # 無効な投稿に対して、エラーは出るが、ポストは作成されない
  test "should show errors but not create micropost on invalid submission" do
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: "" } }
    end
    assert_select 'div#error_explanation'
    assert_select 'a[href=?]', '/?page=2' # 正しいページネーションリンク
  end

  # 有効な投稿に対して、ポストを作成する
  test "should create a micropost on valid submission" do
    content = "This micropost really ties the room together"
    assert_difference 'Micropost.count', 1 do # ポスト数が1だけ増えるかな
      post microposts_path, params: { micropost: { content: content } }
    end
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body # HTML内にcontentとマッチする内容が含まれている
  end

  # 自分のプロフィールページにポストのdeleteリンクがあるべき
  test "should have micropost delete links on own profile page" do
    get user_path(@user) # プロフィールパスへGETリクエスト
    assert_select 'a', text: 'delete' # 'delete'の文字のaタグがある
  end

  # 自分のポストは消すことができる
  test "should be able to delete own micropost" do
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference 'Micropost.count', -1 do # ポスト数が1減るかな
      delete micropost_path(first_micropost)
    end
  end

  # 他のユーザーのプロフィール画面にはdeleteリンクがないべき
  test "should not have delete links on other user's profile page" do
    get user_path(users(:archer)) # michaelとしてarcherのページにGETリクエスト
    assert_select 'a', { text: 'delete', count: 0 }
  end
end

class MicropostSidebarTest < MicropostInterface

  test "should display the right micropost count" do
    get root_path
    assert_match "#{@user.microposts.count} microposts", response.body
  end

  # 1つのポストに対して適切な複数形を使用すべき
  test "should user proper pluralization" do
    log_in_as(users(:lana)) # lana(ポストが1件のユーザー)としてログイン
    get root_path # ルートパスにGETリクエスト
    assert_match "1 micropost", response.body
  end
end