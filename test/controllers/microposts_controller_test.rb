require "test_helper"

class MicropostsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @micropost = microposts(:orange)
  end

  test "should redirect create when not logged in" do # ログインなしでポスト投稿を試みるとリダイレクトされる
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: "Lorem ipsum" } }
    end
    assert_redirected_to login_url
  end

  test "should redirect destroy when not logged in" do # ログインなしでポスト削除を試みるとリダイレクトされる
    assert_no_difference 'Micropost.count' do
      delete micropost_path(@micropost) # orangeの投稿に対してDELETEリクエスト
    end
    assert_response :see_other
    assert_redirected_to login_url
  end

  test "should redirect destroy for wrong micropost" do
    log_in_as(users(:michael)) # michaelとしてログイン
    micropost = microposts(:ants) # archerのポストを代入
    assert_no_difference 'Micropost.count' do
      delete micropost_path(micropost) # archerのポスト(ants)にDELETEリクエスト
    end
    assert_response :see_other
    assert_redirected_to root_url # ルートURLにリダイレクト
  end
end
