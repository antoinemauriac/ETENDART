require "test_helper"

class Coaches::CoursesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get coaches_courses_index_url
    assert_response :success
  end

  test "should get show" do
    get coaches_courses_show_url
    assert_response :success
  end
end
