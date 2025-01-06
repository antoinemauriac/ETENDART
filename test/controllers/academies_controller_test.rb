require "test_helper"

class AcademiesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get academies_index_url
    assert_response :success
  end

  test "should get show" do
    get academies_show_url
    assert_response :success
  end
end
