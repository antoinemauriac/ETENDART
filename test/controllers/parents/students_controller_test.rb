require "test_helper"

class Parents::StudentsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get parents_students_index_url
    assert_response :success
  end

  test "should get new" do
    get parents_students_new_url
    assert_response :success
  end

  test "should get show" do
    get parents_students_show_url
    assert_response :success
  end

  test "should get edit" do
    get parents_students_edit_url
    assert_response :success
  end
end
