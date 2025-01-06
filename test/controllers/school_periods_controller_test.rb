require "test_helper"

class SchoolPeriodsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get school_periods_show_url
    assert_response :success
  end
end
