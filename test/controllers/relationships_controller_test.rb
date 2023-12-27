require "test_helper"

class RelationshipsControllerTest < ActionDispatch::IntegrationTest

  test "create should require logged-in user" do
    assert_no_difference 'Relationship.count' do # 未ログインでPOSTしてもリレーションシップに変化がないことを確認
      post relationships_path
    end
    assert_redirected_to login_url
  end

  test "destroy should require logged-in user" do
    assert_no_difference 'Relationship.count' do
      delete relationship_path(relationships(:one)) # michaelがlanaのフォローを解除するリクエスト
    end
    assert_redirected_to login_url
  end
end
