require "test_helper"

class Users::FirstLoginsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get users_first_logins_show_url
    assert_response :success
  end

  test "should get update" do
    get users_first_logins_update_url
    assert_response :success
  end
end
